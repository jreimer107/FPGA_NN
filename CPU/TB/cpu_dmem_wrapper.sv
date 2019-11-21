module cpu_dmem_wrapper(clk, rst_n);

input clk, rst_n;

wire [15:0] data_to_mem, data_to_cpu;
wire [15:0] data_addr;
wire dmem_ren, dmem_wren;

wire [15:0] data_to_bus;


cpu CPU(
    .clk(clk),
    .rst_n(rst_n),
    .bus_data_in(16'h0),
	.bus_data_out(),
    .dmem_ren(dmem_ren), 
    .dmem_wren(dmem_wren),
	.dmem_addr(data_addr),  
    .dmem_data_to(data_to_mem),
    .dmem_data_from(data_to_cpu)
);

ram DMEM(
    .address_a(data_addr[10:0]),
    .address_b(),
    .clock(clk),
    .data_a(data_to_mem),
    .data_b(256'h0),
    .rden_a(dmem_ren),
    .rden_b(1'b0),
    .wren_a(dmem_wren),
    .wren_b(1'b0),
    .q_a(data_to_cpu),
    .q_b()
);


endmodule