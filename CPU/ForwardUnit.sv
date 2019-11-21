module ForwardUnit (
    input exmemregwrite,
    input exmemregwrite_prev,
    input [3:0]exmemregrd,
    input [3:0]exmemregrd_prev, 
    input [3:0]idexregrs,
    input [3:0]idexregrt,
    input idexmemwrite,
    input exmemmemread,
    output forwarda,
    output forwardb,
    output forwardc
    );
    
    wire [2:0]exhazard;
    wire [1:0]memhazard;

    assign exhazard[0] = exmemregwrite & (exmemregrd != 4'h0) & (exmemregrd == idexregrs) & (idexmemwrite & exmemmemread & (exmemregrd == idexregrs));
    assign exhazard[1] = exmemregwrite & (exmemregrd != 4'h0) & (exmemregrd == idexregrt);
    assign exhazard[2] = exmemregwrite_prev & (exmemregrd_prev != 4'h0) & (exmemregrd_prev == idexregrs);

    assign forwardb = exhazard[0] ? 1 : 0;
    assign forwardc = exhazard[2] ? 1 : 0;
    assign forwarda = exhazard[1] ? 1 : 0;

endmodule