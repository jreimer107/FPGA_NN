module execute (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input ex_regwrite_in,
    input [1:0]ex_memtoreg_in,
    input ex_memread_in,
    input ex_memwrite_in,
    input [4:0]ex_aluop,
    input ex_alusrc,
    input [15:0]ex_reg_1,
    input [15:0]ex_reg_2,
    input [15:0]ex_imm,
    input [3:0]ex_regrdaddr1_in,
    input [3:0]ex_regrdaddr2_in,
    input [3:0]ex_regwraddr_in,
    input mem_regwrite_in,
	input mem_memread_in,
	input [3:0] mem_regwraddr_in,
	input [15:0]wb_regwrdata_in,
	output [2:0] mem_flag,
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
	wire forwarda;
	wire forwardb;

    assign rst = ~rst_n;

    ForwardUnit U_ForwardUnit(
        .exmemregwrite(mem_regwrite_in),
        .exmemregrd(mem_regwraddr),
        .idexregrs(ex_regrdaddr2_in),
        .idexregrt(ex_regrdaddr1_in),
        .idexmemwrite(ex_memwrite_in),
        .exmemmemread(mem_memread_in),
        .forwarda(forwarda),
        .forwardb(forwardb)
    );

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

    assign ex_aluin1 = forwarda ? wb_regwrdata_in : ex_reg_1;
    assign ex_aluin2 = ex_alusrc ? ex_imm : (forwardb ? wb_regwrdata_in : ex_reg_2);
    assign ex_aluctrl = ex_aluop;
    assign ex_alu_src2 = forwardb ? wb_regwrdata_in : ex_reg_2;

	always @ (posedge clk or posedge rst) 
	begin
		ex_regwrite_out  <= ex_regwrite_in;
		ex_memtoreg_out  <= ex_memtoreg_in;
		ex_memread_out   <= ex_memread_in;
		ex_memwrite_out  <= ex_memwrite_in;
		ex_alu_out       <= ex_aluout;
		ex_alu_src2_out  <= ex_alu_src2;
		ex_regwraddr_out <= ex_regwraddr_in;
	end

endmodule