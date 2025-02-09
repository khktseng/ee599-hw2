module accumulation_buffer
#( 
  parameter DATA_WIDTH = 64,
  parameter BANK_ADDR_WIDTH = 7,
  parameter [BANK_ADDR_WIDTH : 0] BANK_DEPTH = 128
)(
  input clk,
  input rst_n,
  input switch_banks,
  
  input ren,
  input [BANK_ADDR_WIDTH - 1 : 0] radr,
  output [DATA_WIDTH - 1 : 0] rdata,
  
  input wen,
  input [BANK_ADDR_WIDTH - 1 : 0] wadr,
  input [DATA_WIDTH - 1 : 0] wdata,

  input ren_wb,
  input [BANK_ADDR_WIDTH - 1 : 0] radr_wb,
  output [DATA_WIDTH - 1 : 0] rdata_wb
);

  // Implement an accumulation buffer with the dual-port SRAM (ram_sync_1r1w)
  // provided. This SRAM allows one read and one write every cycle. To read
  // from it you need to supply the address on radr and turn ren (read enable)
  // high. The read data will appear on rdata port after 1 cycle (1 cycle
  // latency). To write into the SRAM, provide write address and data on wadr
  // and wdata respectively and turn write enable (wen) high. 
  
  // Accumulation buffer is similar to a double buffer, but one of its banks
  // has both a read port (ren, radr, rdata) and a write port (wen, wadr,
  // wdata). This bank is used by the systolic array to store partial sums and
  // then read them back out. The other bank has a read port only (ren_wb,
  // radr_wb, rdata_wb). This bank is used to read out the final output (after
  // accumulation is complete) and send it out of the chip. The reason for
  // adopting two banks is so that we can overlap systolic array processing,
  // and data transfer out of the accelerator (otherwise one of them will
  // stall while the other is taking place). Note: both srams will be 1r1w, 
  // but the logical operation will be as described above.

  // If switch_banks is high, you need to switch the functionality of the two
  // banks at the positive edge of the clock. That means, you will use the bank
  // you were previously using for data transfer out of the chip for systolic
  // array and vice versa.

  // Your code starts here

  wire wen0;
  wire wen1;
  wire ren0;
  wire ren1;
  wire [BANK_ADDR_WIDTH-1:0] radr0;
  wire [BANK_ADDR_WIDTH-1:0] radr1;
  wire [DATA_WIDTH-1:0] rdata0;
  wire [DATA_WIDTH-1:0] rdata1;

  reg bank_sel_r; // 0: bank 0 writeback. 1: bank 1 writeback

  assign wen0 = bank_sel_r ? wen : 0;
  assign wen1 = bank_sel_r ? 0 : wen;
  assign ren0 = bank_sel_r ? ren : ren_wb;
  assign ren1 = bank_sel_r ? ren_wb : ren;
  assign radr0 = bank_sel_r ? radr : radr_wb;
  assign radr1 = bank_sel_r ? radr_wb : radr;
  assign rdata = bank_sel_r ? rdata0 : rdata1;
  assign rdata_wb = bank_sel_r ? rdata1 : rdata0;

  ram_sync_1r1w #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (BANK_ADDR_WIDTH),
    .DEPTH (BANK_DEPTH)
  ) buf0 (
    .clk (clk),
    .wen (wen0),
    .wadr (wadr),
    .wdata (wdata),
    .ren (ren0),
    .radr (radr0),
    .rdata(rdata0)
  );

  ram_sync_1r1w #(
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (BANK_ADDR_WIDTH),
    .DEPTH (BANK_DEPTH)
  ) buf1 (
    .clk (clk),
    .wen (wen1),
    .wadr (wadr),
    .wdata (wdata),
    .ren (ren1),
    .radr (radr1),
    .rdata(rdata1)
  );

  always_ff @(posedge clk) begin
    if (~rst_n) begin
      bank_sel_r <= 'b0;
    end else begin
      if (switch_banks) begin
        bank_sel_r <= ~bank_sel_r;
      end
    end
  end

  // Your code ends here
endmodule
