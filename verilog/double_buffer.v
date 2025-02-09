module double_buffer
#( 
  parameter DATA_WIDTH = 64,
  parameter BANK_ADDR_WIDTH = 7,
  parameter BANK_DEPTH = 128
)(
  input clk,
  input rst_n,
  input switch_banks,
  input ren,
  input [BANK_ADDR_WIDTH - 1 : 0] radr,
  output [DATA_WIDTH - 1 : 0] rdata,
  input wen,
  input [BANK_ADDR_WIDTH - 1 : 0] wadr,
  input [DATA_WIDTH - 1 : 0] wdata
);
  // Implement a double buffer with the dual-port SRAM (ram_sync_1r1w)
  // provided. This SRAM allows one read and one write every cycle. To read
  // from it you need to supply the address on radr and turn ren (read enable)
  // high. The read data will appear on rdata port after 1 cycle (1 cycle
  // latency). To write into the SRAM, provide write address and data on wadr
  // and wdata respectively and turn write enable (wen) high. 
  
  // You can implement both double buffer banks with one dual-port SRAM.
  // Think of one bank consisting of the first half of the addresses of the
  // SRAM, and the second bank consisting of the second half of the addresses.
  // If switch_banks is high, you need to switch the bank you are reading with
  // the bank you are writing on the clock edge.

  // Your code starts here

  localparam DEPTH = 2 * BANK_DEPTH;
  localparam ADDR_WIDTH = BANK_ADDR_WIDTH + 1;

  reg bank_sel_r;
  wire [ADDR_WIDTH-1:0] radr_sel;
  wire [ADDR_WIDTH-1:0] wadr_sel;
  
  assign radr_sel = {bank_sel_r, radr};
  assign wadr_sel = {~bank_sel_r, wadr};

  ram_sync_1r1w #(
    DATA_WIDTH,
    ADDR_WIDTH,
    DEPTH
  ) buf0 (
    .clk (clk),
    .wen (wen),
    .wadr (wadr_sel),
    .wdata (wdata),
    .ren (ren),
    .radr (radr_sel),
    .rdata (rdata)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      bank_sel_r <= 'b0;
    end else begin
      if (switch_banks) begin
        bank_sel_r <= ~bank_sel_r;
      end
    end
  end
 
  // Your code ends here
endmodule
