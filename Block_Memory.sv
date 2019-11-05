/* Block_Memory.sv
 * This module is the controller for the block memory. This is the combination
 * of instruction and data memory. There are three interfaces: instruction
 * read, data read/write, and node read. Instruction and data read take in a
 * 16 bit address and output a 16 bit result in the same cycle. Data write does
 * the same but writing, obviously. Node read instead outputs 16 16-bit values,
 * each contiguous from the given address.
 *
 * Though a 16bit address is input, only 11 bits are actually used.
 * @input iclk is the clock. Duh.
 * @input irst_n is an active-low reset.
 * @input iInstAddr is the address of the instruction to fetch.
 * @input iDataAddr is the address of the data to retrieve.
 * @input dataWrite determines if data is being written to memory.
 * @input iData is the data to be written to memory.
 * @input iNodeAddr is the base address of the node values to fetch.
 * @output oInstr is the fetched instruction.
 * @output oData is the fetched data.
 * @output oNodes are the 16 fetched nodes.
*/
module Block_Memory(iclk, irst_n, iInstAddr, iDataAddr, dataWrite, iData,
	iNodeAddr, oInstr, oData, oNodes);

input iclk, irst_n;
input dataWrite;
input [15:0] iInstrAddr, iDataAddr, iNodeAddr;

output [23:0] oInstr;
output [15:0] oData;
output [15:0] oNodes [15:0];

reg [23:0] imem [512:0] /* synthesis ram_init_file = "instructions.mif" */;
reg [15:0] dmem [2048:0];

always_ff @(posedge clk, negedge rst)
	if (!irst_n) begin
		dmem <= '{default:0};
	end
	else if (dataWrite)
		dmem[iDataAddr[10:0]] <= iData;

assign oInstr = imem[iInstAddr[8:0]];
assign oData = dmem[iDataAddr[10:0]];
assign oNodes = dmem[iNodeAddr[10:0] + 16:iNodeAddr[10:0]];

endmodule