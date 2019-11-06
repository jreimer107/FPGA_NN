module BMem_tb();

reg clk, rst_n;
reg dataWrite;
reg[15:0] iInstAddr, iDataAddr, iNodeAddr, iData;

wire [23:0] oInstr;
wire[15:0] oData;
wire [15:0] oNodes [15:0];

Block_Memory iDUT(.iclk(clk), .irst_n(rst_n), .iInstAddr(iInstAddr),
    .iDataAddr(iDataAddr), .idataWrite(dataWrite), .iData(iData),
    .iNodeAddr(iNodeAddr), .oInstr(oInstr), .oData(oData), .oNodes(oNodes));

initial begin
    clk = 0;
    rst_n = 0;
    @(posedge clk)
    rst_n = 1;
    iNodeAddr = 0;
    iInstAddr = 0;
    iDataAddr = 0;
end

always
    #10 clk = ~clk;

endmodule