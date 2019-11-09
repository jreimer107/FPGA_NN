module execute (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input ex_regdst_in,
    input ex_regwrite_in,
    input [1:0]ex_memtoreg_in,
    input ex_memread_in,
    input ex_memwrite_in,
    input [4:0]ex_aluop,
    input ex_alusrc,
    input [15:0]ex_reg_1,
    input [15:0]ex_reg_2,
    input [15:0]ex_imm,
    input [3:0]ex_regrdaddr1,
    input [3:0]ex_regrdaddr2,
    input [3:0]ex_regwraddr_in,
	input mem_regdst,
    input mem_regwrite,
	input mem_memread,
	input [15:0]wb_regwrdata,
	input [1:0]forwarda,
    input [1:0]forwardb,
	output [2:0] mem_flag,
	output reg ex_regdst_out,
	output reg ex_regwrite_out,
	output reg [1:0] ex_memtoreg_out,
	output reg ex_memread_out,
	output reg ex_memwrite_out,
	output reg [15:0] ex_alu_out,
	output reg [15:0] ex_alu_src2_out,
	output reg [3:0] ex_regwraddr_out
);

	wire rst;
	
    wire [15:0]ex_alu_src2;
	wire [15:0]ex_aluin1;
    wire [15:0]ex_aluin2;
    wire [4:0]ex_aluctrl;
    wire [15:0]ex_aluout;
    wire ex_aluovfl;

    assign rst = ~rst_n;

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // ex stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    // ForwardUnit U_ForwardUnit(
        // .exmemregwrite(mem_regwrite),
        // .exmemregrd(mem_regwraddr),
    // //    .memwbregwrite(wb_regwrite),
    // //    .memwbregrd(wb_regwraddr),
        // .idexregrs(ex_regrdaddr2),
        // .idexregrt(ex_regrdaddr1),
        // .idexmemwrite(ex_memwrite),
        // .exmemmemread(mem_memread),
    // //    .forward_disable_for_branch_flush(forward_disable_for_branch_flush),
        // .forwarda(forwarda),
        // .forwardb(forwardb)
    // );

    // verified, except PC
    ALU U_ALU(
        .a(ex_aluin1),
        .b(ex_aluin2),
        .ctrl(ex_aluctrl),
        .out(ex_aluout),
        .ovfl(ex_aluovfl)
        );

    // verified
    FLAG U_FLAG(
        .clk(clk),
        .rst(rst),
        .opcode(ex_aluctrl),
        .aluout(ex_aluout),
        .aluovfl(ex_aluovfl),
        .flag(mem_flag)
        );

    assign ex_aluin1 = forwarda ? wb_regwrdata : ex_reg_1;
    assign ex_aluin2 = ex_alusrc ? ex_imm : (forwardb ? wb_regwrdata : ex_reg_2);
    assign ex_aluctrl = ex_aluop;
    assign ex_alu_src2 = forwardb ? wb_regwrdata : ex_reg_2;

    // assign ex_alu_out = ex_aluout;
	
	always @ (posedge clk or posedge rst) 
	begin
		ex_regdst_out    <= ex_regdst_in;
		ex_regwrite_out  <= ex_regwrite_in;
		ex_memtoreg_out  <= ex_memtoreg_in;
		ex_memread_out   <= ex_memread_in;
		ex_memwrite_out  <= ex_memwrite_in;
		ex_alu_out       <= ex_aluout;
		ex_alu_src2_out  <= ex_alu_src2;
		ex_regwraddr_out <= ex_regwraddr_in;
	end

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // mem stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    // copy from TA
    // memory1cdata u_memory1c_data(
        // .data_out(mem_dataout), 
        // .data_in(mem_datain), 
        // .addr(mem_dataaddr), 
        // .enable(mem_dataena), 
        // .wr(mem_datawr), 
        // .clk(clk), 
        // .rst(rst)
        // );

    // assign mem_mem_out = mem_dataout;
    // // assign mem_datain = mem_alu_src2;
    // // mem to mem forward
    // assign mem_datain = mem_alu_src2;
    // assign mem_dataaddr = mem_alu_out;
    // assign mem_dataena = (mem_memwrite | mem_memread);
    // assign mem_datawr = mem_memwrite;

    // // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // //
    // // wb stage
    // //
    // // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    // assign wb_regwrdata = mem_memtoreg ? mem_alu_out : mem_mem_out;

endmodule