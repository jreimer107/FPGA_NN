module cpu_dmem_acc_wrapper(
    input clk, rst_n,
    input pc_advance,
    input [3:0] reg_index,
    output [15:0] pc_out, reg_out,
    output [23:0] instr_out,
    output halt
);

wire [15:0] data_to_mem, data_to_cpu;
wire [15:0] data_addr;
wire dmem_ren, dmem_wren;

//Accel
wire [15:0] acc_data;
wire bus_wr;
tri [15:0] databus = bus_wr ? acc_data : 16'hz;
wire acc_en;
// wire acc_start;
wire [2:0] acc_regaddr;
wire acc_done;

//CCD mock
wire ccd_en;
wire ccd_done = 1'b0;

// wire halt;

// DMEM
wire cpu_dmem_ren;
wire cpu_dmem_wren;
wire [10:0] cpu_dmem_addr;
wire [15:0] cpu_dmem_data;
wire [15:0] dmem_cpu_data;

wire [6:0] ccd_dmem_addr;
wire [255:0] ccd_dmem_data;
wire ccd_dmem_wren;
wire [15:0] DRAM_weight,BRAM_Addr_In,  BRAM_Addr_out, output_neuron;
wire [15:0] [15:0] BRAM_input;
cpu CPU(
    .clk(clk),
    .rst_n(rst_n),

	//DMEM interface
    .dmem_ren(cpu_dmem_ren), 
    .dmem_wren(cpu_dmem_wren),
	.dmem_addr(cpu_dmem_addr),  
    .dmem_data_to(cpu_dmem_data),
    .dmem_data_from(dmem_cpu_data),

	// Accel interface
    .accel_done(acc_done),
    //.accel_start(acc_start),
    .accel_en(acc_en),
    .bus_wr(bus_wr),
    .bus_data(acc_data),
    //.bus_accregaddr(acc_regaddr),

	// CCD interface
    .ccd_done(ccd_done),
    .ccd_en(ccd_en),

	// Debug signals
    .halt(halt),
    .pc_out(pc_out),
    .reg_index(reg_index),
    .reg_out(reg_out),
    .pc_advance(pc_advance),
    .instr_out(instr_out)
);

ram DMEM(
    .clock(clk),

	// CPU interface
    .address_a(BRAM_Addr_out),
    .data_a(cpu_dmem_data),
    .rden_a(cpu_dmem_ren),
    .wren_a(Wr_BRAM),
    .q_a(dmem_cpu_data),

    // Shared Accel/CCD interface
	.address_b(BRAM_Addr_In[11:4]),  //Need to mux this when implementing Accel
    .data_b(ccd_dmem_data),
    .rden_b(Rd_BRAM), 		//For accel
    .wren_b(ccd_dmem_wren),
    .q_b(BRAM_input)		//For accel
);


Accelerator Acc0 (
	.clk(clk),                   // Clock
	.reset(rst_n),                 // Asynchronous reset active low
	.DRAMdata (DRAM_weight),
	.data_bus (acc_data),
	.BRAM_data (BRAM_input),
	.busrdwr(bus_wr),
	.CPUEnable(acc_en),
	.DVAL(Rd_done),
	.BRAM_Addr_In (BRAM_Addr_In),
	.out_addr_current (BRAM_Addr_out),
	.Rd_BRAM_current (Rd_BRAM),
	.Wr_BRAM_current (Wr_BRAM),
	.SRAM_RdReq (SRAM_RdReq),
	.cpu_neuron_done(acc_done),
	.output_neuron (output_neuron)
);


endmodule