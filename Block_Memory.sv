module Block_Memory(iclk, irst_n, iInstAddr, iDataAddr, dataWrite, iData, iNodeAddr, oInstr, oData, oNodes);

input iclk, irst_n;
input dataWrite;
input [15:0] iInstrAddr, iDataAddr, iNodeAddr;
output [15:0] oInstr, oData;

output [15:0] oNodes [15:0];

reg [15:0] memory [2048:0];

wire [2048:0] instLoc, dataLoc, nodeLoc;
decoder Decoder_11_2048(iInstAddr[10:0], instLoc);
decoder Decoder_11_2048(iDataAddr[10:0], dataLoc);
decoder Decoder_11_2048(iNodeAddr[10:0], nodeLoc);

always_ff @(posedge clk, negedge rst) begin
	if (!irst_n)
		memory <= '{default:0};
	else begin
		if (dataWrite)
			memory[dataLoc] <= iData;
	end
end

assign oInstr = memory[instLoc];
assign oData = memory[dataLoc];
assign oNodes = memory[nodeLoc+16:nodeLoc];

endmodule