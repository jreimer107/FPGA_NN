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
 * @input iWriteBack is whether or not to write back data.
 * @input iWriteBackReg is the register to write back to.
 * @input iWriteBackData is the data to write.
 * @input iNVZ is the output of the flag register in the EX phase.
 * @output oData1 is the contents of the first source register.
 * @output oData2 is the contents of the second source register.
 * @output oImm is the sign-extended immediate value
 */
module fetchdecode(iclk, irst_n, iWriteReg, iWriteRegAddr, iWriteRegData,
	iMemtoReg, iBustoReg, iNVZ, iStall, oData1, oData2, oImm, oWriteReg, oWriteRegAddr,
	oMemtoReg, oBustoReg, oMemRead, oMemWrite, oBusWrite, oOpcode, oALUSrc, 
	oSr1, oSr2);

localparam Branch = 5'b00111;
localparam ImmL = 5'b01000;
localparam ImmH = 5'b01001;
localparam Load = 5'b01010;
localparam Store = 5'b01011;
localparam DbLoad = 5'b01100;
localparam DbStore = 5'b01101;

input iclk, irst_n;

reg [15:0] PC;

// Imem interface
wire [23:0] instr_temp;
reg [23:0] instr;

// Writeback, from MEM/WB phase
input iWriteReg;
input iMemtoReg;
input iBustoReg;
input [3:0] iWriteRegAddr;
input [15:0] iWriteRegData;

// Stall for reads
input iStall;

// Condition codes, from EX phase
input [2:0] iNVZ;

// Register Data
output reg [15:0] oData1, oData2;

output reg [4:0] oOpcode;

// Register Imm
output reg [15:0] oImm;

output reg [3:0] oSr1, oSr2;

output reg oMemtoReg;
output reg oBustoReg;
output reg oMemRead;
output reg oMemWrite;
output reg oBusWrite;
output reg oALUSrc;

// WriteBack registers for execute stage
output reg oWriteReg;
output reg [3:0] oWriteRegAddr;

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
wire branch = (opcode == Branch) & conditionResult;
CCodeEval cce(.branch(branch), .C(condition), .NVZ(iNVZ), .cond_true(conditionResult));



// Instruction memory
wire [15:0] branchAddr = PC + {{8{instr[10]}}, instr[10:3]} + 1;
reg [15:0] next_PC;
rom imem(.address(next_PC[7:0]), .clock(iclk), .q(instr_temp), .rden(irst_n));
always @(*) begin
	instr = instr_temp;
	if (iStall) begin
		next_PC = PC;
		instr = 24'b001010000000000000000000; //Noop
	end
	else if (branch) begin
		next_PC = branchAddr;
	end
	else begin
		next_PC = PC + 1;
	end
end

// Output data
always @(posedge iclk or negedge irst_n) begin
	if (!irst_n) begin
		PC <= -1;
		oImm <= 0;
		oData1 <= 0;
		oData2 <= 0;
		oOpcode <= 0;
		oSr1 <= 0;
		oSr2 <= 0;
	end
	else begin
		PC <= next_PC;
		oImm <= (opcode == ImmL) ? {{8{1'b0}}, instr[10:3]} : ((opcode == ImmH) ? {instr[10:3], {8{1'b0}}} : 16'h0);
		oData1 <= registers[sr1];
		oData2 <= registers[sr2];
		oOpcode <= opcode;
		oSr1 <= sr1;
		oSr2 <= sr2;
	end
end

// Control outputs
always @(posedge iclk or negedge irst_n) begin
	if(!irst_n) begin
		oWriteReg <= 0;
		oWriteRegAddr <= 0;
		oMemtoReg <= 0;
		oBustoReg <= 0;
		oBusWrite <= 0;
		oMemRead <= 0;
		oMemWrite <= 0;
		oALUSrc <= 0;
	end
	else begin
		oWriteReg <= (opcode == Store | opcode == Branch) ? 0 : 1;
		oWriteRegAddr <= (opcode == Store | opcode == Branch) ? 0 : dest;
		oMemtoReg <= (opcode == Load) ? 1 : 0;
		oBustoReg <= (opcode == DbLoad) ? 1 : 0;
		oBusWrite <= (opcode == DbStore) ? 1 : 0; 
		oMemRead <= (opcode == Load) ? 1 : 0;
		oMemWrite <= (opcode == Store) ? 1 : 0;
		case(opcode)
			ImmL, ImmH, Load, Store, DbLoad, DbStore: oALUSrc <= 1;
			default: oALUSrc <= 0;	
		endcase
	end
end

// Register file
always @(posedge iclk or negedge irst_n) begin
	if (!irst_n) begin
		registers <= '{default:0};
	end
	else begin
		if (iWriteReg | iMemtoReg | iBustoReg)
			registers[iWriteRegAddr] <= iWriteRegData;
		registers[0] <= 16'h0;
	end
end

endmodule