module cpu (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    output hlt,
    output [15:0]pc
);

    wire rst;
    wire rst_d;

    // if
    wire [15:0]if_pc; // pc from pc reg
    wire [15:0]if_inst; // inst for pc
    // id
    wire [15:0]id_pc;
    wire [15:0]id_inst;
    wire id_regdst;
    wire id_regwrite;
    wire [1:0]id_memtoreg;
    wire id_memread;
    wire id_memwrite;
    wire id_branch;
    wire [3:0]id_aluop;
    wire id_alusrc;
    wire [15:0]id_reg_1; // output 1 of registerfile
    wire [15:0]id_reg_2; // output 2 of registerfile
    wire [15:0]id_imm;
    wire [3:0]id_regrdaddr1;
    wire [3:0]id_regrdaddr2;
    wire [2:0]id_ctrlcode;
    wire [3:0]id_regwraddr;
    // ex
    wire [15:0]ex_inst;
    wire ex_regdst;
    wire ex_regwrite;
    wire [1:0]ex_memtoreg;
    wire ex_memread;
    wire ex_memwrite;
    wire ex_branch;
    wire [3:0]ex_aluop;
    wire ex_alusrc;
    wire [15:0]ex_reg_1;
    wire [15:0]ex_reg_2;
    wire [15:0]ex_imm;
    wire [15:0]ex_alu_out;
    wire [15:0]ex_alu_src2;

    wire [15:0]ex_aluin1;
    wire [15:0]ex_aluin2;
    wire [3:0]ex_aluctrl;
    wire [15:0]ex_aluout;
    wire ex_aluovfl;
    wire [3:0]ex_regrdaddr1;
    wire [3:0]ex_regrdaddr2;
    wire [3:0]ex_regwraddr;

    // mem
    wire mem_regdst;
    wire mem_regwrite;
    wire [1:0]mem_memtoreg;
    wire mem_memread;
    wire mem_memwrite;
    wire mem_branch;
    wire [15:0]mem_alu_out;
    wire [15:0]mem_alu_src2;
    wire [3:0]mem_regwraddr;
    wire [15:0]mem_mem_out;

    wire [15:0]mem_dataout;
    wire [15:0]mem_datain;
    wire [15:0]mem_dataaddr;
    wire mem_dataena;
    wire mem_datawr;

    wire [15:0]if_mem_pc_next;
    wire [2:0]mem_flag;
    wire mem_branchtaken;

    // wb
    wire wb_regdst;
    wire wb_regwrite;
    wire [1:0]wb_memtoreg;
    wire [15:0]wb_alu_out;
    wire [15:0]wb_mem_out;
    wire [15:0]wb_pc_plus2;
    wire [3:0]wb_regwraddr;
    wire [15:0]wb_regwrdata;

    // stall and flush
    // ifid
    wire ifid_stall;
    wire ifid_flush;
    // idex
    wire idex_stall;
    wire idex_flush;
    // exmem
    wire exmem_stall;
    wire exmem_flush;
    // memwb
    wire memwb_stall;
    wire memwb_flush;

    wire halt_stall_pc;
    wire loaduse_stall_flush;
    // wire loaduse_stall_flush_d;
    wire branch_flush;
    wire forward_disable_for_branch_flush;

    wire [1:0]forwarda;
    wire [1:0]forwardb;

    assign rst = ~rst_n;

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // if stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    assign ifid_stall = loaduse_stall_flush | halt_stall_pc;
    assign ifid_flush = 1'b0;

    // when loaduse stall is asserted, it is stalled.
    // when halt stall is asserted, it is stalled.
    PC U_PC(
        .clk(clk),
        .rst(rst),
        .stall(ifid_stall), 
        .pc_in(if_mem_pc_next),// come from ex stage.
        .pc_out(pc)
        );

    assign if_pc = pc;

    // copy from TA
    memory1cinst u_memory1c_inst(
        .data_out(if_inst), 
        .data_in(16'b0), 
        .addr(if_pc), 
        .enable(1'b1), 
        .wr(1'b0), 
        .clk(clk), 
        .rst(rst)
        );

    // when loaduse stall is asserted, it is stalled.
    // when halt stall is asserted, it is stalled.
    // when branch flush is asserted, it is flushed.
    IFIDBuf U_IFIDBuf(
        .clk(clk),
        .rst(rst),
        .stall(ifid_stall),
        .flush(ifid_flush),
        .pc_in(if_pc),
        .inst_in(if_inst),
        .pc_out(id_pc),
        .inst_out(id_inst)
        );

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // id stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    // verified
    REGADDRGEN U_REGADDRGEN (
        .inst(id_inst),
        .regrdaddr1(id_regrdaddr1), // generated in ID, used to read reg in ID
        .regrdaddr2(id_regrdaddr2), // generated in ID, used to read reg in ID
        .regwraddr(id_regwraddr), // generated in ID, used to write reg in WB
        .signeximm(id_imm), // generated in ID, used in EX
        .ctrl(id_ctrlcode) // generated in ID, used for branch decision in EX
    );

    // pc control unit cover from if, id, ex, to mem stage
    PC_control U_PC_control(
        .clk(clk),
        .rst(rst),
        .C(id_ctrlcode), // ctrlcode in ID
        .I(ex_imm[8:0]), // imm in EX
        .F(mem_flag), // flag in MEM
        .opcode(ex_inst[15:12]), // inst in EX
        .branch(mem_branch), // inst in EX
        .branch_flush(branch_flush),
        .PC_in(if_pc), // pc in IF
        .PC_BR_in(ex_reg_1), // register output 1 in EX, for BR inst
        .PC_out(if_mem_pc_next), // generated in MEM, to be use as new pc
        .PC_plus2(wb_pc_plus2), // generated in WB, to be used in WB for PCS write back to register file
        .branchtaken(mem_branchtaken)
        );

    HazardDetectUnit U_HazardDetectUnit(
        .clk(clk),
        .rst(rst),
        .opcode(id_inst[15:12]),
        .prebranch(ex_branch),
        .preprebranch(mem_branch),
        .mem_branchtaken(mem_branchtaken),
        .ifidRegRs(id_regrdaddr2),
        .ifidRegRt(id_regrdaddr1),
        .idexMemRead(ex_memread),

        .ifidMemWrite(id_memwrite),
        
        .idexRegRt(ex_regwraddr),
        .branch_flush(branch_flush), // output
        .forward_disable_for_branch_flush(forward_disable_for_branch_flush), // output
        .loaduse_stall_flush(loaduse_stall_flush), // output
        .halt_stall_pc(halt_stall_pc),
        .halt(hlt)
    );

    dff U_dff0_rst(.q(rst_d), .d(rst), .wen(1'b1), .clk(clk), .rst(1'b0));
    // verified
    CONTROL U_CONTROL(
        .rst(rst_d),
        .opcode(id_inst[15:12]),
        .regdst(id_regdst),
        .branch(id_branch),
        .memread(id_memread),
        .memtoreg(id_memtoreg),
        .aluop(id_aluop),
        .memwrite(id_memwrite),
        .alusrc(id_alusrc),
        .regwrite(id_regwrite)
        );

    // verified
    RegisterFile U_RegisterFile(
        .clk(clk),  
        .rst(rst), 
        .SrcReg1(id_regrdaddr1), // rt
        .SrcReg2(id_regrdaddr2), // rs
        .DstReg(wb_regwraddr), // rd
        .WriteReg(wb_regwrite), 
        .DstData(wb_regwrdata), 
        .SrcData1(id_reg_1), 
        .SrcData2(id_reg_2)
        );

    assign idex_stall = 1'b0;
    // dff U_dff0_loaduse_stall_flush(.q(loaduse_stall_flush_d), .d(loaduse_stall_flush), .wen(1'b1), .clk(clk), .rst(rst));
    assign idex_flush = loaduse_stall_flush;
    // when branch, it is flushed.
    IDEXBuf U_IDEXBuf(
        .clk(clk),    // Clock
        .rst(rst),  // Asynchronous reset active low
        .stall(idex_stall),
        .flush(idex_flush),
        // wb
        .regdst_in(id_regdst),
        .regwrite_in(id_regwrite),
        .memtoreg_in(id_memtoreg),
        // mem
        .memread_in(id_memread),
        .memwrite_in(id_memwrite),
        .branch_in(id_branch),
        // ex
        .aluop_in(id_aluop),
        .alusrc_in(id_alusrc),
        // opr
        .inst_in(id_inst),
        .reg_1_in(id_reg_1),
        .reg_2_in(id_reg_2),
        .imm_in(id_imm),
        .IFIDRegRs_in(id_regrdaddr2),
        .IFIDRegRt1_in(id_regrdaddr1),
        .IFIDRegRt2_in(id_regrdaddr1),
        .IFIDRegRd_in(id_regwraddr),

        // wb
        .regdst_out(ex_regdst),
        .regwrite_out(ex_regwrite),
        .memtoreg_out(ex_memtoreg),
        // mem
        .memread_out(ex_memread),
        .memwrite_out(ex_memwrite),
        .branch_out(ex_branch),
        // ex
        .aluop_out(ex_aluop),
        .alusrc_out(ex_alusrc),
        // opr
        .inst_out(ex_inst),
        .reg_1_out(ex_reg_1),
        .reg_2_out(ex_reg_2),
        .imm_out(ex_imm),
        .IFIDRegRs_out(ex_regrdaddr2),
        .IFIDRegRt1_out(ex_regrdaddr1),
        .IFIDRegRt2_out(ex_regrdaddr1),
        .IFIDRegRd_out(ex_regwraddr)
        );

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // ex stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    ForwardUnit U_ForwardUnit(
        .exmemregwrite(mem_regwrite),
        .exmemregrd(mem_regwraddr),
        .memwbregwrite(wb_regwrite),
        .memwbregrd(wb_regwraddr),
        .idexregrs(ex_regrdaddr2),
        .idexregrt(ex_regrdaddr1),
        .idexmemwrite(ex_memwrite),
        .exmemmemread(mem_memread),
        .forward_disable_for_branch_flush(forward_disable_for_branch_flush),
        .forwarda(forwarda),
        .forwardb(forwardb)
    );

    // ********************************************
    // mem to mem forward, loaded value is used to store
    // find a store in ex, following a load in mem
    wire wb_memwrite;
    wire wb_memread;
    wire [15:0]mem_regrdaddr2;
    wire mem2memforward;
    // buffer ex_regrdaddr2 to be mem_regrdaddr2
    Register U_Register_for_read_reg_buffer(
        .clk(clk),  
        .rst(rst), 
        .D(~exmem_flush ? {12'b0,ex_regrdaddr2} : 16'b0), 
        .WriteReg(~exmem_stall),
        .ReadEnable1(1'b1), 
        .ReadEnable2(), 
        .Bitline1(mem_regrdaddr2), 
        .Bitline2()
        );
    assign mem2memforward = (wb_memread & mem_memwrite & (mem_regrdaddr2[3:0] == wb_regwraddr)) ? 1'b1 : 1'b0;
    // ********************************************

    // verified, except PC
    ALU U_ALU(
        .a(ex_aluin1),
        .b(ex_aluin2),
        .ctrl(ex_aluctrl),
        .out(ex_aluout),
        .ovfl(ex_aluovfl)
        );

    // verified
    FLAG U_FLAG(
        .clk(clk),
        .rst(rst),
        .opcode(ex_inst[15:12]),
        .aluout(ex_aluout),
        .aluovfl(ex_aluovfl),
        .stall(branch_flush),
        .flag(mem_flag)
        );

    assign ex_aluin1 = (forwarda == 2'b01) ? wb_regwrdata : ((forwarda == 2'b10) ? mem_alu_out : ex_reg_1);
    // assign ex_aluin2 = (forward_disable_for_branch_flush) ? (ex_alusrc ? ex_imm : ex_reg_2) : ((forwardb == 2'b01) ? wb_regwrdata : ((forwardb == 2'b10) ? mem_alu_out : (ex_alusrc ? ex_imm : ex_reg_2)));
    assign ex_aluin2 = (forward_disable_for_branch_flush) ? (ex_alusrc ? ex_imm : ex_reg_2) : (ex_alusrc ? ex_imm : ((forwardb == 2'b01) ? wb_regwrdata : ((forwardb == 2'b10) ? mem_alu_out : ex_reg_2)));
    assign ex_aluctrl = ex_aluop;
    assign ex_alu_src2 = (forwardb == 2'b01) ? wb_regwrdata : ex_reg_2;

    assign ex_alu_out = ex_aluout;
    assign exmem_stall = 1'b0;
    assign exmem_flush = branch_flush;
    EXMEMBuf U_EXMEMBuf(
        .clk(clk),    // Clock
        .rst(rst),  // Asynchronous reset active low
        .stall(exmem_stall),
        .flush(exmem_flush),
        // wb
        .regdst_in(ex_regdst),
        .regwrite_in(ex_regwrite),
        .memtoreg_in(ex_memtoreg),
        // mem
        .memread_in(ex_memread),
        .memwrite_in(ex_memwrite),
        .branch_in(ex_branch),
        // opr
        .alu_out_in(ex_alu_out),
        .alu_src2_in(ex_alu_src2),
        .reg_source_in(ex_regwraddr),

        // wb
        .regdst_out(mem_regdst),
        .regwrite_out(mem_regwrite),
        .memtoreg_out(mem_memtoreg),
        // mem
        .memread_out(mem_memread),
        .memwrite_out(mem_memwrite),
        .branch_out(mem_branch),
        // opr
        .alu_out_out(mem_alu_out),
        .alu_src2_out(mem_alu_src2),
        .reg_source_out(mem_regwraddr)
        );

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // mem stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    // copy from TA
    memory1cdata u_memory1c_data(
        .data_out(mem_dataout), 
        .data_in(mem_datain), 
        .addr(mem_dataaddr), 
        .enable(mem_dataena), 
        .wr(mem_datawr), 
        .clk(clk), 
        .rst(rst)
        );

    assign mem_mem_out = mem_dataout;
    // assign mem_datain = mem_alu_src2;
    // mem to mem forward
    assign mem_datain = mem2memforward ? wb_mem_out : mem_alu_src2;
    assign mem_dataaddr = mem_alu_out;
    assign mem_dataena = (mem_memwrite | mem_memread);
    assign mem_datawr = mem_memwrite;

    assign memwb_stall = 1'b0;
    assign memwb_flush = 1'b0;

    EXMEMBuf U_MEMWBBuf(
        .clk(clk),    // Clock
        .rst(rst),  // Asynchronous reset active low
        .stall(memwb_stall),
        .flush(memwb_flush),
        // wb
        .regdst_in(mem_regdst),
        .regwrite_in(mem_regwrite),
        .memtoreg_in(mem_memtoreg),
        // mem
        .memread_in(mem_memread),
        .memwrite_in(mem_memwrite),
        .branch_in(1'b0),
        // opr
        .alu_out_in(mem_alu_out),
        .alu_src2_in(mem_mem_out),
        .reg_source_in(mem_regwraddr),

        // wb
        .regdst_out(wb_regdst),
        .regwrite_out(wb_regwrite),
        .memtoreg_out(wb_memtoreg),
        // mem
        .memread_out(wb_memread),
        .memwrite_out(wb_memwrite),
        .branch_out(),
        // opr
        .alu_out_out(wb_alu_out),
        .alu_src2_out(wb_mem_out),
        .reg_source_out(wb_regwraddr)
        );
    // MEMWBBuf U_MEMWBBuf(
    //     .clk(clk),    // Clock
    //     .rst(rst),  // Asynchronous reset active low
    //     .stall(memwb_stall),
    //     .flush(memwb_flush),
    //     // wb
    //     .regdst_in(mem_regdst),
    //     .regwrite_in(mem_regwrite),
    //     .memtoreg_in(mem_memtoreg),
    //     // opr
    //     .alu_out_in(mem_alu_out),
    //     .mem_out_in(mem_mem_out),
    //     .reg_source_in(mem_regwraddr),

    //     // wb
    //     .regdst_out(wb_regdst),
    //     .regwrite_out(wb_regwrite),
    //     .memtoreg_out(wb_memtoreg),
    //     // opr
    //     .alu_out_out(wb_alu_out),
    //     .mem_out_out(wb_mem_out),
    //     .reg_source_out(wb_regwraddr)
    //     );

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // wb stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    assign wb_regwrdata = (wb_memtoreg == 0) ? wb_alu_out : ((wb_memtoreg == 1) ? wb_mem_out : ((wb_memtoreg == 2) ? wb_pc_plus2 : 16'b0));

endmodule