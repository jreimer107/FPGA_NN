module ForwardUnit (
    input exmemregwrite,
    input [3:0]exmemregrd,
    input [3:0]idexregrs,
    input [3:0]idexregrt,
    input idexmemwrite,
    input exmemmemread,
    output forwarda,
    output forwardb
    );
    
    wire [1:0]exhazard;
    wire [1:0]memhazard;

    assign exhazard[0] = exmemregwrite & (exmemregrd != 4'h0) & (exmemregrd == idexregrs) & (idexmemwrite & exmemmemread & (exmemregrd == idexregrs));
    assign exhazard[1] = exmemregwrite & (exmemregrd != 4'h0) & (exmemregrd == idexregrt);

    assign forwardb = exhazard[0] ? 1 : 0;
    assign forwarda = exhazard[1] ? 1 : 0;

endmodule