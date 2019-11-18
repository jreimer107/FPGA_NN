module flag_reg(clk, rst, opcode, alu_ovfl, alu_out, dis, NVZ);
	input clk, rst;
	input [3:0] opcode;
	input alu_ovfl;
	input [15:0] alu_out;
	input dis;
	output [2:0] NVZ;


	wire A, B, C, D;
	assign {A,B,C,D} = opcode;

	//TODO: This from 552, needs to be changed to fit our ISA.
	
	// localparam  ADD = 4'b0000;
	// localparam  SUB = 4'b0001;
	// localparam  XOR = 4'b0011;
	// localparam  SLL = 4'b0100;
	// localparam  SRA = 4'b0101;
	// localparam  ROR = 4'b0110;
	//assign WriteEn = dis ? 3'b000 : (opcode == ADD || opcode == SUB) ? 3'b111 :
	//    (opcode == XOR || opcode == SLL || opcode == SRA || opcode == ROR) ? 3'b001 : 
	//        3'b000;

	//Write Enables to FLAG register
	wire [2:0] WriteEn; //NVZ order
	assign WriteEn = dis ? 3'b000 : 
					~|opcode[3:1] ? 3'b111 :
					(~A & (~C | (B & ~D) | (~B & D))) ? 3'b001 : 3'b000;

	//FLAG inputs
	wire [2:0] NVZ_in;
	wire [2:0] reg_out;

	assign NVZ_in = {alu_out[15], alu_ovfl, ~|alu_out};
	dff negative(.q(reg_out[2]), .d(NVZ_in[2]), .wen(WriteEn[2]), .clk(clk), .rst(rst));
	dff overflow(.q(reg_out[1]), .d(NVZ_in[1]), .wen(WriteEn[1]), .clk(clk), .rst(rst));
	dff zero	(.q(reg_out[0]), .d(NVZ_in[0]), .wen(WriteEn[0]), .clk(clk), .rst(rst));
	
	

	assign NVZ[0] = WriteEn[0] ? NVZ_in[0] : reg_out[0]; // bypass reg on instructions that don't update NVZ (branches)
	assign NVZ[1] = WriteEn[1] ? NVZ_in[1] : reg_out[1];
	assign NVZ[2] = WriteEn[2] ? NVZ_in[2] : reg_out[2];
	
	
endmodule
