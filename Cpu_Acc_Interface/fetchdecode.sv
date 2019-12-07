/* fetchdecode.sv
 * This module forms the first stage of the cpu, a combination of the fetch and
 * decode stages of a 5-stage pipeline. It interacts with Block Memory to fetch
 * instructions, and of course the next stage, execute. To the execute phase,
 * this phase passes the fetched instruction as well as the register data. 
 *
 * This phase also expects values in return from both EX and MEM/WB. From EX,
 * it expects the NVZ values of the current instruction. From MEM/WB, it
 * expects a few signals to describe if and how writeback should be done.
 *
 * @input iWriteBack_en is whether or not to write back data.
 * @input iWriteBackReg is the register to write back to.
 * @input iWriteBackData is the data to write.
 * @input iNVZ is the output of the flag register in the EX phase.
 * @output oData1 is the contents of the first source register.
 * @output oData2 is the contents of the second source register.
 * @output oImm is the sign-extended immediate value
 */
module fetchdecode(
	input clk, rst_n,

	// Writeback, from MEM/WB phase
	input iWriteBack_en,
	input [3:0] iWriteBackAddr,
	input [15:0] iWriteBackData,

	// Condition codes, from EX phase
	input [2:0] iNVZ,

	input iHalt,

	// Decoded Instruction Content
	output reg [4:0] oOpcode,
	output reg [15:0] oImm,
	output reg [3:0] oSr1, 
	output reg [3:0] oSr2,

	// Register Data
	output reg [15:0] oData1,
	output reg [15:0] oData2,

	// WriteBack registers for execute stage
	output reg oAlutoReg,
	output reg oMemtoReg,
	output reg oBustoReg,
	output reg [3:0] oWriteBackAddr,

	//CCD Interface
	input iCCD_done,
	output oCCD_en,

	// Accelerator Interface
	input iACC_done,
	// output oACC_en,   //These two go directly to accelerator
	// output oACC_start,

	// Control Signals for later stages
	output reg oALUSrc,
	output reg oMemRead,
	output reg oMemWrite,
	output reg oBusWrite,

	// Testing/Demo signals
	input iPC_advance,
	input [3:0] iRegIndex,
	output reg [15:0] PC,
	output [15:0] oReg_Out,
	output [23:0] oInstr_out
);

localparam Branch = 5'b00111;
localparam ImmL = 5'b01000;
localparam ImmH = 5'b01001;
localparam Load = 5'b01010;
localparam Store = 5'b01011;
localparam DbLoad = 5'b01100;
localparam DbStore = 5'b01101;

// Imem interface
// reg [15:0] PC;
wire [23:0] instr;
wire [23:0] instr_temp;

// Instruction components. Immediate is not used here.
wire [4:0] opcode = instr[23:19];
wire [3:0] sr1 = instr[14:11];
wire [3:0] sr2 = instr[10:7];
wire [3:0] dest = instr[18:15];
wire [2:0] condition = instr[2:0];

// Register File
reg [15:0] registers [15:0];

// Evaluate condition result based on NVZ and current code.
wire conditionResult;
wire branch = conditionResult;
CCodeEval cce(.opcode(opcode), .C(condition), .NVZ(iNVZ), .cond_true(conditionResult));

// Instruction memory
wire [15:0] branchAddr = PC + {{8{instr[10]}}, instr[10:3]} + 1;
wire [15:0] next_PC;

rom imem(.address(next_PC[7:0]), .clock(clk), .q(instr_temp), .rden(rst_n));

// Branching vs PC advancement
//assign instr = (oOpcode == Load | iHalt | !iPC_advance) ? 24'h280000 : instr_temp;

assign instr = (oOpcode == Load | iHalt) ? 24'h280000 : instr_temp;

// assign next_PC = (branch == 1'b1) ? branchAddr :
// 				 (opcode == Load | !iPC_advance) ? PC :
// 				 PC + 1;

assign next_PC = (branch == 1'b1) ? branchAddr :
				 (opcode == Load) ? PC :
				 PC + 1;  

// PC register
always_ff @(posedge clk, negedge rst_n)
	if (!rst_n)
		PC <= -1;
	else
		PC <= (iHalt == 1'b1) ? PC : next_PC;


// Output data
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		oImm <= 0;
		oData1 <= 0;
		oData2 <= 0;
		oOpcode <= 0;
		oSr1 <= 0;
		oSr2 <= 0;
	end
	else begin
		oImm <= (opcode == ImmL) ? {{8{1'b0}}, instr[10:3]} : ((opcode == ImmH) ? {instr[10:3], {8{1'b0}}} : 16'h0);
		oOpcode <= opcode;
		oSr1 <= sr1;
		oSr2 <= (opcode == Store) ? dest :  sr2;
		
		oData1 <= registers[sr1];
		oData2 <= (opcode == Store) ? registers[dest] : registers[sr2];
	end
end

// Control outputs
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		// Writeback signals
		oAlutoReg <= 0;
		oMemtoReg <= 0;
		oBustoReg <= 0;
		oWriteBackAddr <= 0;

		oBusWrite <= 0;
		oMemRead <= 0;
		oMemWrite <= 0;
		oALUSrc <= 0;
	end
	else begin
		//Writeback signals
		oAlutoReg <= !(opcode == Store | opcode == Load | opcode == Branch);
		oMemtoReg <= (opcode == Load);
		oBustoReg <= (opcode == DbLoad);
		oWriteBackAddr <= (opcode == Store | opcode == Branch) ? 0 : dest;

		oBusWrite <= (opcode == DbStore);
		oMemRead <= (opcode == Load);
		oMemWrite <= (opcode == Store);
		case(opcode)
			ImmL, ImmH, Load, Store, DbLoad, DbStore: oALUSrc <= 1;
			default: oALUSrc <= 0;	
		endcase
	end
end

// Register file
always_ff @(negedge clk, negedge rst_n) begin
	if (!rst_n) begin
		registers <= '{default:0};
	end
	else begin
		if (iWriteBack_en & ~iHalt)
			registers[iWriteBackAddr] <= iWriteBackData;
		registers[0] <= 16'h0;

		// Status register inputs
		registers[15][0] <= iCCD_done;
		registers[15][2] <= iACC_done;
	end
end

assign oCCD_en = registers[15][1];
// assign oACC_en = registers[15][3];
assign oACC_start = registers[15][4];

// Testing/demoing
assign oReg_Out = registers[iRegIndex];
assign oInstr_out = instr_temp;
endmodule