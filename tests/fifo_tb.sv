`define DATA_WIDTH (4)
`define FIFO_DEPTH (3)
`define COUNTER_WIDTH (1)

module fifo_tb;
	reg clk;
    reg rst_n;
    reg clr;

	integer clk_cnt;

    always #5 clk =~clk;
	initial clk <= 0;
	initial clk_cnt = 0;

	always @(posedge clk) clk_cnt = clk_cnt + 1;

	logic [`DATA_WIDTH-1:0] din;
	logic enq;
	logic full_n;
	logic [`DATA_WIDTH-1:-] dout;
	logic deq;
	logic empty_n;

    fifo #(
      .DATA_WIDTH(`DATA_WIDTH), 
      .FIFO_DEPTH(`FIFO_DEPTH), 
      .COUNTER_WIDTH(`COUNTER_WIDTH)
    ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .din(din),
      .enq(enq),
      .full_n(full_n),
      .dout(dout),
      .deq(deq),
      .empty_n(empty_n),
      .clr(clr)
    );

	initial begin
		$monitor("#%d: rst_n=%b, din=%0h, enq=%b, deq=%b, dout=%0h", clk_cnt, rst_n, din, enq, deq, dout);
		rst_n = 0;
		clr = 0;
		din = 0;
		enq = 0;
		deq = 0;

		#15;
		rst_n = 1;
		#20;
		din = 'hC;
		enq = 1;
		#10;
		enq = 0;
		#10;
		din = 'hA;
		enq = 1;
		#10;
		enq = 0;
		#10;
		deq = 1;
		#20;

		

		$finish;
	end
endmodule