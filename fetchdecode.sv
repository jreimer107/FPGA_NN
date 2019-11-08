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
 * @input iInstr is the instruction fetched from Block Memory.
 * @input iWriteBack is whether or not to write back data.
 * @input iWriteBackReg is the register to write back to.
 * @input iWriteBackData is the data to write.
 * @input iNVZ is the output of the flag register in the EX phase.
 * @output oInstrAddr is the address of the instruction to fetch. AKA the PC.
 * @output oData1 is the contents of the first source register.
 * @output oData2 is the contents of the second source register.
 */
module fetchdecode(iclk, irst_n, iInstr, oInstrAddr, iWriteBack, iWriteBackReg,
	iWriteBackData, iNVZ, oData1, oData2);

localparam Branch = 5'b01000;
localparam BranchRegister = 5'b01001;

input iclk, irst_n;

// BMem interface
input [15:0] iInstr;
output [15:0] oInstrAddr;

// Writeback, from MEM/WB phase
input iWriteBack;
input [3:0] iWriteBackReg;
input [15:0] iWriteBackData;

// Condition codes, from EX phase
input [2:0] iNVZ;

// Register Data
output [15:0] oData1, oData2;

// Instruction components. Immediate is not used here.
wire [4:0] opcode = iInstr[4:0];
wire [3:0] dest = iInstr[8:5]; 
wire [3:0] sr1 = iInstr[12:9];
wire [3:0] sr2 = iInstr[16:13];
wire [7:0] imm = iInstr[20:13];
wire [2:0] condition = iInstr[23:21];

// Evaluate condition result based on NVZ and current code.
wire conditionResult;
wire branch = opcode == Branch || opcode == BranchRegister;
CCodeEval cce(.C(condition), .NVZ(iNVZ), .cond_true(conditionResult));

// PC register
reg [15:0] PC;
always_ff @(posedge iclk, negedge irst_n)
	if (!irst_n)
		PC <= 0;
	else
		PC <= (branch & conditionResult) ? PC + 3*(imm + 1) : PC + 3;

assign oInstrAddr = PC;

// Register File
reg [15:0] registers [15:0];
always @(posedge iclk, negedge irst_n)
	if (!irst_n)
		registers <= '{default:0};
	else begin
		if (iWriteBack)
			registers[iWriteBackReg] <= iWriteBackData;
	end

// Register data
assign oData1 = registers[sr1];
assign oData2 = registers[sr2];

