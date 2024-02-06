// Write a directed test for the accumulation buffer module. Make sure you test 
// all its ports and its behaviour when your switch banks.
`define DATA_WIDTH 64
`define BANK_ADDR_WIDTH 7
`define BANK_DEPTH 128

module accumulation_buffer_tb;
	logic clk;
	logic rst_n;
	logic switch_banks;
	
	logic ren;
	logic [`BANK_ADDR_WIDTH-1:0] radr;
	logic [`DATA_WIDTH-1:0] rdata;

	logic wen;
	logic [`BANK_ADDR_WIDTH-1:0] wadr;
	logic [`DATA_WIDTH-1:0] wdata;

	logic ren_wb;
	logic [`BANK_ADDR_WIDTH-1:0] radr_wb;
	logic [`DATA_WIDTH-1:0] rdata_wb;

	accumulation_buffer #(
		.DATA_WIDTH(`DATA_WIDTH),
		.BANK_ADDR_WIDTH(`BANK_ADDR_WIDTH),
		.BANK_DEPTH(`BANK_DEPTH)
	) DUT (
		.clk(clk),
		.rst_n(rst_n),
		.switch_banks(switch_banks),
		.ren(ren),
		.radr(radr),
		.rdata(rdata),
		.wen(wen),
		.wadr(wadr),
		.wdata(wdata),
		.ren_wb(ren_wb),
		.radr_wb(radr_wb),
		.rdata_wb(rdata_wb)
	);

	always #5 clk = ~clk;

	integer i;
	initial begin
		clk <= 0;
		rst_n <= 0;
		ren <= 0;
		radr <= 0;
		wen <= 0;
		wadr <= 'h1F;
		wdata <= 'hDEADBEEF;
		ren_wb <= 0;
		radr_wb <= 0;
		#20 rst_n <= 1;
		#40;

		for (i = 0; i < 16; i = i + 1) begin
			wen <= 1;
			wadr <= i;
			wdata <= i;
			#10;
		end

		wen <= 0;
		switch_banks <= 1;
		#10;
		switch_banks <= 0;

		for (i = 0; i < 16; i = i + 1) begin
			wen <= 1;
			wadr <= i;
			wdata <= i * 'h10;

			ren_wb <= 1;
			radr_wb <= i;
			#10;
			assert(rdata_wb == i);
		end

		ren_wb <= 0;
		wen <= 0;
		#10;

		for (i = 0; i < 16; i = i + 1) begin
			ren <= 1;
			radr <= i;
			#10;
			assert(rdata == i * 'h10);
		end
		ren <= 0;
		switch_banks <= 1;
		#10;
		switch_banks <= 0;
		#20;

		// Test memory write forwarding
		for (i = 0; i < 16; i++) begin
			wen <= 1;
			wadr <= i;
			wdata <= i * 'h10;

			ren <= 1;
			radr <= i;

			ren_wb <= 1;
			radr_wb <= i;
			#10;
			assert(rdata == i * 'h10);
			assert(rdata_wb == i * 'h10);
		end
		wen <= 0;
		ren <= 0;
		ren_wb <= 0;
		#10;
		$finish;
	end


endmodule