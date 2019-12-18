module cpu_dmem_acc_wrapper(
    input clk, rst_n,
    //input pc_advance,
    //input [3:0] reg_index,
    output [15:0] pc_out,
	 //output [15:0] reg_out,
    //output [23:0] instr_out,
	 //output [15:0] output_neuron,
    output halt, 
	 output reg [15:0][15:0] rd_buf, 
	 output sdram_rd_req,
	 output rd_done
);





wire [15:0] data_to_mem, data_to_cpu;
wire [15:0] data_addr;
wire dmem_ren, dmem_wren;

//Accel
wire [15:0] acc_data;
wire bus_wr;
wire acc_en;
// wire acc_start;
wire [2:0] acc_regaddr;
wire acc_done;

//CCD mock
wire ccd_en;
wire ccd_done = 1'b0;

// DMEM
wire cpu_dmem_ren;
wire cpu_dmem_wren;
wire [10:0] cpu_dmem_addr, bram_addr_a;
wire [15:0] cpu_dmem_data;
wire [15:0] dmem_cpu_data;

wire [6:0] ccd_dmem_addr;
wire [255:0] ccd_dmem_data;
wire ccd_dmem_wren;
wire [15:0][15:0] DRAM_weight;
wire [15:0]BRAM_Addr_In, BRAM_Addr_out, output_neuron;
wire [15:0] [15:0] BRAM_input;
wire [6:0] bram_addr_b;
wire Rd_BRAM, Wr_BRAM;

tri [15:0] databus = bus_wr ? acc_data : (acc_done ? output_neuron : 16'hz);

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
	.bus_data_in(databus),
    .accel_en(acc_en),
    .bus_wr(bus_wr),
    .bus_data_out(acc_data),
    //.bus_accregaddr(acc_regaddr),

	// CCD interface
    .ccd_done(ccd_done),
    .ccd_en(ccd_en),

	// Debug signals
    .halt(halt),
    .pc_out(pc_out),
    .reg_index(4'b0000),
    .reg_out(reg_out),
    .pc_advance(pc_advance),
    .instr_out(instr_out)
);


//assign bram_addr_b = Rd_BRAM ? BRAM_Addr_In[10:4] : cpu_dmem_wren? cpu_dmem_wren: 7'h0;
assign bram_addr_b = Rd_BRAM ? BRAM_Addr_In[10:4] : ccd_dmem_wren ? ccd_dmem_addr : 7'h0;

wire [255:0] BRAM_data1;
assign BRAM_input[0] = BRAM_data1[15:0];
assign BRAM_input[1] = BRAM_data1[31:16];
assign BRAM_input[2] = BRAM_data1[47:32];
assign BRAM_input[3] = BRAM_data1[63:48];
assign BRAM_input[4] = BRAM_data1[79:64];
assign BRAM_input[5] = BRAM_data1[95:80];
assign BRAM_input[6] = BRAM_data1[111: 96];
assign BRAM_input[7] = BRAM_data1[127:112];
assign BRAM_input[8] = BRAM_data1[143:128];
assign BRAM_input[9] = BRAM_data1[159:144];
assign BRAM_input[10] = BRAM_data1[175:160];
assign BRAM_input[11] = BRAM_data1[191:176];
assign BRAM_input[12] = BRAM_data1[207:192];
assign BRAM_input[13] = BRAM_data1[223:208];
assign BRAM_input[14] = BRAM_data1[239:224];
assign BRAM_input[15] = BRAM_data1[255:240];




ram DMEM(
    .clock(clk),

	// CPU interface
    .address_a(cpu_dmem_addr),
    .data_a(cpu_dmem_data),
    .rden_a(cpu_dmem_ren),
    .wren_a(cpu_dmem_wren),//),
    .q_a(dmem_cpu_data),

    // Shared Accel/CCD interface
	.address_b(bram_addr_b),  //Need to mux this when implementing Accel
    .data_b(ccd_dmem_data),
    .rden_b(Rd_BRAM), 		//For accel
    .wren_b(ccd_dmem_wren),
    .q_b(BRAM_data1)		//For accel
); 

Accelerator Acc0 (
	.clk(clk),                   // Clock
	.reset(rst_n),                 // Asynchronous reset active low
	.SDRAM_FIFO_in (rd_buf),
	.data_bus (acc_data),
	.BRAM_data (BRAM_input),
	.busrdwr(bus_wr),
	.CPUEnable(acc_en),
	.DVAL(rd_done),
	.BRAM_Addr_In (BRAM_Addr_In),
	.out_addr_current (BRAM_Addr_out),
	.Rd_BRAM_current (Rd_BRAM),
	//.Wr_BRAM_current (Wr_BRAM),
	.SRAM_RdReq (sdram_rd_req),// (sdram_rd_req),
	.cpu_neuron_done(acc_done),
	.output_neuron (output_neuron),
	.total_output_neurons(total_output_neurons),
	.total_input_neurons(total_input_neurons),
	.partial_sum(MAC_out),
	.single_mult(single_mult),
	.Number_of_neurons_done(Number_of_neurons_done), 
	.Weight_data_test(Weight_data_test),
	.counter_state (counter_state),
	.accum_sum_t(accum_sum_test),
	.single_sum(single_sum),
	.mac1(mac1),
	.mac2(mac2)
);



//fakeSDRAM F_SD1(.clk (clk), .rst_n(rst_n), .rd_req(sdram_rd_req), .rd_buf(rd_buf), .rd_done(rd_done));

endmodule

//wire [15:0] data_to_mem, data_to_cpu;
//wire [15:0] data_addr;
//wire dmem_ren, dmem_wren;
//
////Accel
//wire [15:0] acc_data;
//wire bus_wr;
//wire acc_en;
//// wire acc_start;
//wire [2:0] acc_regaddr;
//wire acc_done;
//
////CCD mock
//wire ccd_en;
//wire ccd_done = 1'b0;
//
//// DMEM
//wire cpu_dmem_ren;
//wire cpu_dmem_wren;
//wire [10:0] cpu_dmem_addr, bram_addr_a;
//wire [15:0] cpu_dmem_data;
//wire [15:0] dmem_cpu_data;
//
//wire [6:0] ccd_dmem_addr;
//wire [255:0] ccd_dmem_data;
//wire ccd_dmem_wren;
//wire [15:0][15:0] DRAM_weight;
//wire [15:0]BRAM_Addr_In, BRAM_Addr_out;
//wire [15:0] [15:0] BRAM_input;
//wire [6:0] bram_addr_b;
//wire Rd_BRAM, Wr_BRAM;
//
//wire [15:0] output_neuron;
//
//tri [15:0] databus = bus_wr ? acc_data : (acc_done ? output_neuron : 16'hz);
//
//cpu CPU(
//    .clk(clk),
//    .rst_n(rst_n),
//
//	//DMEM interface
//    .dmem_ren(cpu_dmem_ren), 
//    .dmem_wren(cpu_dmem_wren),
//	.dmem_addr(cpu_dmem_addr),  
//    .dmem_data_to(cpu_dmem_data),
//    .dmem_data_from(dmem_cpu_data),
//
//	// Accel interface
//    .accel_done(acc_done),
//    //.accel_start(acc_start),
//	.bus_data_in(databus),
//    .accel_en(acc_en),
//    .bus_wr(bus_wr),
//    .bus_data_out(acc_data),
//    //.bus_accregaddr(acc_regaddr),
//
//	// CCD interface
//    .ccd_done(ccd_done),
//    .ccd_en(ccd_en),
//
//	// Debug signals
//    .halt(halt),
//    .pc_out(pc_out)
//    //.reg_index(reg_index),
//    //.reg_out(reg_out),
//    //.pc_advance(pc_advance),
//    //.instr_out(instr_out)
//);
//
//assign bram_addr_b = Rd_BRAM ? BRAM_Addr_In[10:4] : ccd_dmem_wren ? ccd_dmem_addr : 7'h0;
//// assign bram_addr_a = cpu_dmem_ren ? cpu_dmem_addr : Wr_BRAM ? BRAM_Addr_out[10:0] : 11'h0;
//
//ram DMEM(
//    .clock(clk),
//
//	// CPU interface
//    .address_a(cpu_dmem_addr),
//    .data_a(cpu_dmem_data),
//    .rden_a(cpu_dmem_ren),
//    .wren_a(cpu_dmem_wren),
//    .q_a(dmem_cpu_data),
//
//    // Shared Accel/CCD interface
//	.address_b(bram_addr_b),  //Need to mux this when implementing Accel
//    .data_b(ccd_dmem_data),
//    .rden_b(Rd_BRAM), 		//For accel
//    .wren_b(ccd_dmem_wren),
//    .q_b(BRAM_input)		//For accel
//); 
//
//Accelerator Acc0 (
//	.clk(clk),                   // Clock
//	.reset(rst_n),                 // Asynchronous reset active low
//	.SDRAM_FIFO_in (DRAM_weight),
//	.data_bus (acc_data),
//	.BRAM_data (BRAM_input),
//	.busrdwr(bus_wr),
//	.CPUEnable(acc_en),
//	.DVAL(1'b1), //.DVAL(Rd_done),
//	.BRAM_Addr_In (BRAM_Addr_In),
//	.out_addr_current (BRAM_Addr_out),
//	.Rd_BRAM_current (Rd_BRAM),
//	//.Wr_BRAM_current (Wr_BRAM),
//	.SRAM_RdReq (SRAM_RdReq),
//	.cpu_neuron_done(acc_done),
//	.output_neuron (output_neuron)
//);
//
//
//endmodule