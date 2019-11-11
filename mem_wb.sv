module mem_wb(
	input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
	input mem_regdst_in,
	input mem_regwrite_in,
	input [1:0] mem_memtoreg_in,
	input mem_memread_in,
	input mem_memwrite_in,
	input [15:0] mem_alu_in,
	input [15:0] mem_alu_src2_in,
	output [15:0] wb_regwrdata_out
);
	
	wire [15:0] mem_dataout;
	
	memory1cdata u_memory1c_data(
		.data_out(mem_dataout), 
		.data_in(mem_alu_src2_in), 
		.addr(mem_alu_in), 
		.enable(mem_dataena), 
		.wr(mem_memwrite_in), 
		.clk(clk), 
		.rst(rst)
    );

	assign rst = ~rst_n;

    assign mem_dataena = (mem_memwrite_in | mem_memread_in);
	
	assign wb_regwrdata_out = mem_memtoreg_in ? mem_dataout : mem_alu_in;
	
endmodule