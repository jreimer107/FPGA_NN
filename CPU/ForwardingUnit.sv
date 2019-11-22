module ForwardingUnit (
    input [3:0] ex_sr1, ex_sr2,  // EX ALU source registers
    input [3:0] wb_dest,         // MEMWB Writeback destination
    input wb_en,                 // MEMWB Writeback enable

    output reg [1:0] oForward            // Forward wb_data to alu inputs
);

always_comb
    if (wb_en && wb_dest != 4'h0)
        oForward = {(wb_dest == ex_sr2), (wb_dest == ex_sr1)};
    else
        oForward = 2'b0;

endmodule