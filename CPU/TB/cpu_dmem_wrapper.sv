module cpu_dmem_wrapper(
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

// wire halt;

cpu CPU(
    .clk(clk),
    .rst_n(rst_n),
    .dmem_ren(dmem_ren), 
    .dmem_wren(dmem_wren),
	.dmem_addr(data_addr),  
    .dmem_data_to(data_to_mem),
    .dmem_data_from(data_to_cpu),
    .bus_accel_done(bus_done),
    .bus_accel_start(bus_start),
    .bus_accel_en(bus_en),
    .bus_rdwr(bus_rdwr),
    .bus_data(databus),
    .bus_accregaddr(bus_regaddr),
    .ccd_done(ccd_done),
    .ccd_en(ccd_en),
    .halt(halt),
    .pc_out(pc_out),
    .reg_index(reg_index),
    .reg_out(reg_out),
    .pc_advance(pc_advance),
    .instr_out(instr_out)
);

ram DMEM(
    .address_a(data_addr[10:0]),
    .address_b(),
    .clock(clk),
    .data_a(data_to_mem),
    .data_b(256'h0),
    .rden_a(dmem_ren),
    .rden_b(1'b0),
    .wren_a(dmem_wren & ~halt),
    .wren_b(1'b0),
    .q_a(data_to_cpu),
    .q_b()
);


endmodule