module FLAG (
    input clk,    // Clock
    input rst,  // Asynchronous reset active low
    input [4:0]opcode,
    input [15:0]aluout,
    input aluovfl,
    output [2:0]flag // z, v, n
);

    // wire zeroflag;
    reg [2:0]flagreg;

    // assign zeroflag = (aluout == 16'b0) ? 1'b1 : 1'b0;
    assign flag = flagreg;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            flagreg <= 0;
        end else begin
            case (opcode)
                5'h0: flagreg[2] = (aluout == 16'b0) ? 1'b1 : 1'b0;
                5'h1: flagreg[2] = (aluout == 16'b0) ? 1'b1 : 1'b0;
				5'h2: flagreg[2] = (aluout == 16'b0) ? 1'b1 : 1'b0;
                5'h3: flagreg[2] = (aluout == 16'b0) ? 1'b1 : 1'b0;
                5'h4: flagreg[2] = (aluout == 16'b0) ? 1'b1 : 1'b0;
                default : flagreg[2] = flagreg[2];
            endcase
            case (opcode)
                5'h0: flagreg[1] = aluovfl;
                5'h1: flagreg[1] = aluovfl;
                default : flagreg[1] = flagreg[1];
            endcase
            case (opcode)
                5'h0: flagreg[0] = aluout[15];
                5'h1: flagreg[0] = aluout[15];
                default : flagreg[0] = flagreg[0];
            endcase
            end
    end

endmodule