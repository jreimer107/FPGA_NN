module execute (
    input clk, rst_n,

    // Input Control
    input [4:0] iAluOp,
    input iAluUseImm,

    // Input Data
    input [15:0] iData1,
    input [15:0] iData2,
    input [15:0] iImm,
    input [3:0]  iSr1,
    input [3:0]  iSr2,
    input [15:0] iWriteBackData,

    // Forwarding
    input [1:0] iForward,

    // ALU result
    output reg [15:0] oAluOut,
    output reg [15:0] oData2,
    
    // Condition Code
    output reg [2:0] oNVZ,

    // Piplined Source and Destination
    input iAlutoReg,
    input iMemtoReg,
    input iBustoReg,
    input [3:0] iDest,
    output reg oAlutoReg,
    output reg oMemtoReg,
    output reg oBustoReg,
    output reg [3:0] oDest,
    output reg [3:0] oSr1,

    // Pipelined DMem controls
    input iMemRead,
    input iMemWrite,
    input iBusWrite,
    output reg oMemRead,
    output reg oMemWrite,
    output reg oBusWrite
);

wire [15:0] aluout;
wire aluovfl;

// Forward writeback data if indicated
wire [15:0] aluin1, aluin2;
assign aluin1 = iForward[0] ? iWriteBackData : iData1;
assign aluin2 = iAluUseImm ? iImm : (iForward[1] ? iWriteBackData : iData2);
ALU U_ALU(
    .a(aluin1),
    .b(aluin2),
    .ctrl(iAluOp),
    .out(aluout),
    .ovfl(aluovfl)
);

FLAG U_FLAG(
    .clk(clk),
    .rst_n(rst_n),
    .iOpcode(iAluOp),
    .iAluOut(aluout),
    .iAluOvfl(aluovfl),
    .oNVZ(oNVZ)
);

// Pipeline Register
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        oAlutoReg  <= 0;
        oMemtoReg  <= 0;
        oBustoReg  <= 0;
        oMemRead   <= 0;
        oMemWrite  <= 0;
        oAluOut    <= 0;
        oData2     <= 0;
        oDest      <= 0;
        oBusWrite  <= 0;
        oSr1       <= 0;
    end
    else begin
        oAlutoReg  <= iAlutoReg;
        oMemtoReg  <= iMemtoReg;
        oBustoReg  <= iBustoReg;
        oMemRead   <= iMemRead;
        oMemWrite  <= iMemWrite;
        oAluOut    <= aluout;
        oData2     <= iForward[1] ? iWriteBackData : iData2;
        oDest      <= iDest;
        oBusWrite  <= iBusWrite;
        oSr1       <= iSr1;
    end
end

endmodule
