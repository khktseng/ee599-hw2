`define DATA_WIDTH (4)
`define FIFO_DEPTH (3)
`define COUNTER_WIDTH (1)
`define TEST_LENGTH (100)

interface fifo_if (input bit clk);
  logic rst_n;
  logic [`DATA_WIDTH - 1 : 0] din;
  logic enq;
  logic full_n;
  logic [`DATA_WIDTH - 1 : 0] dout;
  logic deq;
  logic empty_n;
  logic clr;
endinterface

// Transaction Object
class fifo_item;
  rand bit [`DATA_WIDTH - 1 : 0] din;
  rand bit enq;
  rand bit deq;
  bit [`DATA_WIDTH - 1 : 0] dout;

  function void print(int id = "");
    $display("T=%0t [transaction_id=%0d] din=%h enq=%d deq=%h dout=%h", $time, id, din, enq, deq, dout);
  endfunction
endclass;

// Driver applies the generated stimulus to DUT
class driver;
  virtual fifo_if vif;
  mailbox drv_mbx;
  
  task run();
    $display ("T=%0t [Write driver] Starting ...", $time);
    
    // drive inputs at falling edges so that they are ready for the next rising edge

    @ (negedge vif.clk);  // first negative edge is at 40ns
    forever begin
      fifo_item transaction;
      drv_mbx.get(transaction);

      // if full then cannot enqueue
      if (!vif.full_n) begin
        transaction.enq = 1'b0;
      end

      // if empty then cannot dequeue
      if (!vif.empty_n) begin
        transaction.deq = 1'b0;
      end

      // send the signals to interface
      vif.din = transaction.din;
      vif.enq = transaction.enq;
      vif.deq = transaction.deq;

      @ (negedge vif.clk);
    end
  endtask
endclass

// Monitor captures data from interface and sends the transaction to scoreboard
class monitor; 
  virtual fifo_if vif;
  mailbox scb_mbx; // mailbox connected to scoreboard


  task run();
    $display("T=%0t [Read monitor] Starting ...", $time);
    forever begin
      fifo_item transaction = new;

      // wait for rising edges so that synchronous signals are updated
      @ (posedge vif.clk); // first positive edge is at 30ns
      
      transaction.din = vif.din;
      transaction.dout = vif.dout;
      transaction.enq = vif.enq;
      transaction.deq = vif.deq;
      
      // send transaction to scoreboard
      scb_mbx.put(transaction);
    end
  endtask
endclass

class scoreboard;
  mailbox scb_mbx;
  int resp_id;
  reg [`DATA_WIDTH - 1 : 0] expected_data;
  // create a "golden" fifo to track the correct behavior
  reg [`DATA_WIDTH - 1 : 0] data_queue[0 : `FIFO_DEPTH - 1];
  int get_idx = 0;
  int put_idx = 0;
  bit full = 0;
  bit empty = 1;

  task run();
    forever begin
      fifo_item transaction;
      resp_id = 0;

      // the initial data is garbage since no stimulus applied yet, skip it
      scb_mbx.get(transaction);  // at 30ns
      // set the initial expected_data to the initial dout to pass the first comparison
      expected_data = transaction.dout; 

      while(resp_id < `TEST_LENGTH) begin
        scb_mbx.get(transaction);  // first mail arrives at 50ns
        transaction.print(resp_id);

        // Comparison
        if (transaction.dout !== expected_data) begin
          $display("T=%0t [Scoreboard] Error! Received = %h, expected = %h", $time, transaction.dout, expected_data);
        end else begin
          $display("T=%0t [Scoreboard] Pass! Received = %h, expected = %h", $time, transaction.dout, expected_data);
        end

        // Update golden model
        if (transaction.enq) begin
          data_queue[put_idx] = transaction.din;
          put_idx = (put_idx + 1) % `FIFO_DEPTH;
          empty = 0; // since we just push something, cannot be empty
          if (put_idx == get_idx) begin
            full = 1;
          end else begin
            full = 0;
          end
        end

        if (transaction.deq) begin
          get_idx = (get_idx + 1) % `FIFO_DEPTH;
          full = 0; // since we just pop something, cannot be full
          if (put_idx == get_idx) begin
            empty = 1;
          end else begin
            empty = 0;
          end
        end

        // update expected_data for next transaction
        // when FIFO is empty, dout always shows the last dequeued data (this is how fifo.v behaves)        
        if (!empty) begin
          expected_data = data_queue[get_idx];
        end  

        resp_id = resp_id + 1;
      end
      $finish;
    end
  endtask
endclass

// Environment class contains all verification components
class env;
  driver            d0;           
  monitor           m0;           
  scoreboard        s0;           
  mailbox           scb_mbx;      // maillbox connecting monitor and scoreboard
  virtual fifo_if   vif;          

  function new();
    d0 = new; 
    m0 = new;
    s0 = new;
    scb_mbx = new();
    
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;
  endfunction

  virtual task run();
    d0.vif = vif;
    m0.vif = vif;

    fork
      s0.run();
      d0.run();
      m0.run();    
    join_any 
  endtask   
endclass


class test;
  env e0;
  mailbox drv_mbx;
  int stim_id;

  function new();
    drv_mbx = new();
    e0 = new();
  endfunction

  virtual task run();
    e0.d0.drv_mbx = drv_mbx;
    fork 
      e0.run();
    join_none

    apply_stim();
  endtask

  virtual task apply_stim();
    fifo_item transaction;
    $display ("T=%0t [Test] Starting write stimulus ...", $time);

    stim_id = 0;
    while(stim_id < `TEST_LENGTH) begin
      transaction = new;
      transaction.randomize();
      stim_id = stim_id + 1;
      drv_mbx.put(transaction);
    end

  endtask
endclass

module fifo_tb;

    reg clk;
    reg rst_n;
    reg clr;

    always #10 clk =~clk;
    
    fifo_if _if (clk);

    fifo #(
      .DATA_WIDTH(`DATA_WIDTH), 
      .FIFO_DEPTH(`FIFO_DEPTH), 
      .COUNTER_WIDTH(`COUNTER_WIDTH)
    ) dut (
      .clk(_if.clk),
      .rst_n(_if.rst_n),
      .din(_if.din),
      .enq(_if.enq),
      .full_n(_if.full_n),
      .dout(_if.dout),
      .deq(_if.deq),
      .empty_n(_if.empty_n),
      .clr(_if.clr)
    );

    assign _if.rst_n = rst_n;
    assign _if.clr = clr;

    initial begin
        test t0;

        clk <= 0;
        rst_n <= 0;
        clr <= 0;
        #20 rst_n <= 1;
        t0 = new(); 
        t0.e0.vif = _if;
        t0.run();
    end

    initial begin
        $vcdplusfile("dump.vcd");
        $vcdplusmemon();
        $vcdpluson(0, fifo_tb);
        `ifdef FSDB
        $fsdbDumpfile("dump.fsdb");
    		$fsdbDumpvars(0, fifo_tb);
    		$fsdbDumpMDA();
			  `endif
        #20000000;
        $finish(2);
    end

endmodule
