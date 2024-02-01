// Write a directed test for the ifmap double buffer module. Make sure you test 
// all its ports and its behaviour when your switch banks.
`define DATA_WIDTH 16
`define BANK_ADDR_WIDTH 4
`define BANK_DEPTH

module ifmap_double_buffer_tb;
	logic clk;
	logic rst_n;
	logic switch_banks;
	logic ren;
	logic [`BANK_ADDR_WIDTH-1:0] radr;
	logic [`DATA_WIDTH-1:0] rdata;
	logic wen;
	logic [`BANK_ADDR_WIDTH-1:0] wadr;
	logic [`DATA_WIDTH-1:0] wdata;

	always #10 clk = ~clk;

	double_buffer #(
		.DATA_WIDTH(`DATA_WIDTH),
		.BANK_ADDR_WIDTH(`BANK_ADDR_WIDTH),
		.BANK_DEPTH(`BANK_DEPTH)
	) DUT (
		.clk (clk),
		.rst_n (rst_n),
		.switch_banks (switch_banks),
		.ren (ren),
		.radr (radr),
		.rdata (rdata),
		.wen (wen),
		.wadr (wadr),
		.wdata (wdata)
	);

	initial begin
		clk <= 0;
		rst_n <= 1;
		switch_banks <= 0;
		ren <= 0;
		wen <= 0;
		#20 rst_n <= 0;
		#20 rst_n <= 1;

		



	end

endmodule