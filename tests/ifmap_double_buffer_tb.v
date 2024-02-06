// Write a directed test for the ifmap double buffer module. Make sure you test 
// all its ports and its behaviour when your switch banks.
`define DATA_WIDTH 64
`define BANK_ADDR_WIDTH 3
`define BANK_DEPTH 8

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

	integer i;
	initial begin
		clk <= 0;
		rst_n <= 1;
		switch_banks <= 0;
		ren <= 0;
		wen <= 0;
		#20 rst_n <= 0;
		#20 rst_n <= 1;

		for (i = 0; i < 8; i++) begin
			wen <= 1;
			wadr <= i;
			wdata <= i;
			#10;
		end

		wen <= 0;
		switch_banks <= 1;
		#10 switch_banks <= 0;

		for (i = 0; i < 8; i++) begin
			ren <= 0;
			radr <= i;

			wen <= 1;
			wadr <= i;
			wdata <= i * 'h10;
			#10;

			assert(rdata == i);

		end

		wen <= 0;
		ren <= 0;
		switch_banks <= 1;
		#10 switch_banks <= 0;

		for (i = 0; i < 8; i++) begin
			ren <= 0;
			radr <= i;
			assert(rdata == i * 'h10);
		end

		#10;

		$finish;


	end

endmodule