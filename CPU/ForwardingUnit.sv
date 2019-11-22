// module ForwardUnit (
//     input exmemregwrite,
//     input [3:0]exmemregrd,
//     input [3:0]idexregrs,
//     input [3:0]idexregrt,
//     input idexmemwrite,
//     input exmemmemread,
//     output forwarda,
//     output forwardb,
//     output forwardc
//     );
    
//     wire [2:0]exhazard;


//     assign exhazard[0] = exmemregwrite & (exmemregrd != 4'h0) & (exmemregrd == idexregrs) & (idexmemwrite & exmemmemread & (exmemregrd == idexregrs));
//     assign exhazard[1] = exmemregwrite & (exmemregrd != 4'h0) & (exmemregrd == idexregrt);

//     assign forwardb = exhazard[0] ? 1 : 0;
//     assign forwardc = exhazard[2] ? 1 : 0;
//     assign forwarda = exhazard[1] ? 1 : 0;

//     //Needs to handle EX/MEMWB forwarding

//     wire exHazard1, exHazard2;


// endmodule

module ForwardingUnit (
    input [3:0] ex_sr1, ex_sr2,  // EX ALU source registers
    input [3:0]wb_dest,         // MEMWB Writeback destination
    input wb_en,                // MEMWB Writeback enable

    output [1:0] oForward            // Forward wb_data to alu inputs
);

always_comb
    if (wb_en && wb_dest != 4'h0)
        oForward = {(wb_dest == ex_sr2), (wb_dest == ex_sr1)};
    else
        oForward = 2'b0;

endmodule