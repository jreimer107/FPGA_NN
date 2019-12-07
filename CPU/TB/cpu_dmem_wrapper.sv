module cpu_dmem_wrapper(clk, rst_n);

input clk, rst_n;

wire [15:0] data_to_mem, data_to_cpu;
wire [15:0] data_addr;
wire dmem_ren, dmem_wren;

//Accel mock
wire [1:0] bus_rdwr;
tri [15:0] databus = bus_rdwr[1] ? 16'h1234 : 16'hz;
wire bus_en;
wire bus_start;
wire [2:0] bus_regaddr;
wire bus_done = bus_en & bus_start;


//CCD mock
wire ccd_en;
wire ccd_done = ccd_en;

wire halt;

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
    .bus_accel_done(bus_done),
    .bus_accel_start(bus_start),
    .bus_accel_en(bus_en),
    .bus_rdwr(bus_rdwr),
    .bus_data(databus),
    .bus_accregaddr(bus_regaddr),

	// CCD interface
    .ccd_done(ccd_done),
    .ccd_en(ccd_en),
<<<<<<< Updated upstream
    .halt(halt)
=======

	// Debug signals
    .halt(halt),
    .pc_out(pc_out),
    .reg_index(reg_index),
    .reg_out(reg_out),
    .pc_advance(pc_advance),
    .instr_out(instr_out)
>>>>>>> Stashed changes
);

ram DMEM(
    .clock(clk),

	// CPU interface
    .address_a(cpu_dmem_addr[10:0]),
    .data_a(cpu_dmem_data),
    .rden_a(cpu_dmem_ren),
    .wren_a(cpu_dmem_wren & ~halt),
    .q_a(dmem_cpu_data),

    // Shared Accel/CCD interface
	.address_b(ccd_dmem_addr),  //Need to mux this when implementing Accel
    .data_b(ccd_dmem_data),
    .rden_b(1'b0), 		//For accel
    .wren_b(ccd_dmem_wren),
    .q_b()		//For accel
);


endmodule