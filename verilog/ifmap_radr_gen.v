module ifmap_radr_gen
#( 
  parameter BANK_ADDR_WIDTH = 8
)(
  input clk,
  input rst_n,
  input adr_en,
  output [BANK_ADDR_WIDTH - 1 : 0] adr,
  input config_en,
  input [BANK_ADDR_WIDTH*8 - 1 : 0] config_data
);

  reg [BANK_ADDR_WIDTH - 1 : 0] config_OX0, config_OY0, config_FX, config_FY, 
    config_STRIDE, config_IX0, config_IY0, config_IC1;
  
  always @ (posedge clk) begin
    if (rst_n) begin
      if (config_en) begin
        {config_OX0, config_OY0, config_FX, config_FY, config_STRIDE, 
         config_IX0, config_IY0, config_IC1} <= config_data; 
      end
    end else begin
      {config_OX0, config_OY0, config_FX, config_FY, config_STRIDE, 
       config_IX0, config_IY0, config_IC1} <= 0;
    end
  end
  
  // This is the read address generator for the input double buffer. It is
  // more complex than the sequential address generator because there are
  // overlaps between the input tiles that are read out.  We have already
  // instantiated for you all the configuration registers that will hold the
  // various tiling parameters (OX0, OY0, FX, FY, STRIDE, IX0, IY0, IC1).
  // You need to generate address (adr) for the input buffer in the same
  // sequence as the C++ tiled convolution that you implemented. Make sure you
  // increment/step the address generator only when adr_en is high. Also reset
  // all registers when rst_n is low.  
  
  // Your code starts here

  reg [BANK_ADDR_WIDTH-1:0] ox0_r;
  reg [BANK_ADDR_WIDTH-1:0] oy0_r;
  reg [BANK_ADDR_WIDTH-1:0] fx_r;
  reg [BANK_ADDR_WIDTH-1:0] fy_r;
  reg [BANK_ADDR_WIDTH-1:0] ic1_r;

  wire row_complete;
  wire col_complete;
  wire fx_complete;
  wire fy_complete;
  wire ic1_complete;
  
  assign row_complete = (ox0_r + config_FX) == config_IX0;
  assign col_complete = ((oy0_r + config_FY) == config_IY0) && row_complete;
  assign fx_complete = (fx_r + 1 == config_FX) && col_complete;
  assign fy_complete = (fy_r + 1 == config_FY) && fx_complete;
  assign ic1_complete = (ic1_r + 1 == config_IC1) && fy_complete;

  assign adr = ox0_r + fx_r + (oy0_r + fy_r) * config_IX0 + config_IX0 * config_IX0 * ic1_r;

  always_ff @(posedge clk) begin
    if (rst_n) begin
      if (adr_en) begin
      if (row_complete) begin
        ox0_r <= 0;
        oy0_r <= oy0_r + config_STRIDE;
      end else begin
        ox0_r <= ox0_r + config_STRIDE;
      end

      if (col_complete) begin
        oy0_r <= 0;
        fx_r <= fx_r + 1;
      end

      if (fx_complete) begin
        fx_r <= 0;
        fy_r <= fy_r + 1;
      end

      if (fy_complete) begin
        fy_r <= 0;
        ic1_r <= ic1_r + 1;
      end

      if (ic1_complete) begin
        ic1_r <= 0;
      end
      end
    end else begin
      ox0_r <= 0;
      oy0_r <= 0;
      fx_r <= 0;
      fy_r <= 0;
      ic1_r <= 0;
    end
  end

  // Your code ends here
endmodule
