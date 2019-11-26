module FLAG (
    input clk, rst_n,

    input [4:0] iOpcode,
    input [15:0] iAluOut,
    input iAluOvfl,

    output [2:0] oNVZ
);

    // Wire and buffer version of flags
    reg [2:0] nvz_ff, nvz;

    // Write enables
    wire N_wren, V_wren, Z_wren;
    assign N_wren = iOpcode <= 5'h1;
    assign V_wren = iOpcode <= 5'h1;
    assign Z_wren = iOpcode <= 5'h4;

    // Get wire result
    assign nvz = {iAluOut[15], iAluOvfl, ~|iAluOut};

    // Register bypassing on output
    assign oNVZ[2] = N_wren ? nvz[2] : nvz_ff[2];
    assign oNVZ[1] = V_wren ? nvz[1] : nvz_ff[1];
    assign oNVZ[0] = Z_wren ? nvz[0] : nvz_ff[0];

    // Buffer wire result
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            nvz_ff <= 3'h0;
        end
        else begin
            if (N_wren)
                nvz_ff[2] <= nvz[2];
            if (V_wren)
                nvz_ff[1] <= nvz[1];
            if (Z_wren)
                nvz_ff[0] <= nvz[0];
        end
    end

endmodule