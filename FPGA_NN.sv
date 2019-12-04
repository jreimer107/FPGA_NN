module FPGA_NN (
	//////////// CLOCK //////////
	input           CLOCK2_50,
	input           CLOCK3_50,
	input           CLOCK4_50,
	input           CLOCK_50,

	///////// SDRAM /////////
	output      [12:0] DRAM_ADDR,
	output      [1:0]  DRAM_BA,
	output             DRAM_CAS_N,
	output             DRAM_CKE,
	output             DRAM_CLK,
	output             DRAM_CS_N,
	inout       [15:0] DRAM_DQ,
	output             DRAM_LDQM,
	output             DRAM_RAS_N,
	output             DRAM_UDQM,
	output             DRAM_WE_N,

	///////// VGA /////////
	output      [7:0]  VGA_B,
	output             VGA_BLANK_N,
	output             VGA_CLK,
	output      [7:0]  VGA_G,
	output             VGA_HS,
	output      [7:0]  VGA_R,
	output             VGA_SYNC_N,
	output             VGA_VS,
	
	///////// GPIO /////////
	inout     [35:0]   GPIO_0,

	//////////// GPIO1, GPIO1 connect to D5M - 5M Pixel Camera //////////
	input		[11:0] D5M_D,
	input		       D5M_FVAL,
	input		       D5M_LVAL,
	input		       D5M_PIXLCLK,
	output		       D5M_RESET_N,
	output		       D5M_SCLK,
	inout		       D5M_SDATA,
	input		       D5M_STROBE,
	output		       D5M_TRIGGER,
	output		       D5M_XCLKIN

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);

wire clk, rst_n;
assign clk = CLOCK_50;
assign rst_n = KEY[0];

//////// SPART wires/reg ////////
wire [2:0] spart_ctrl;
wire spart_rxd, spart_txd;
wire spart_req;
wire [15:0] rx_data, spart_iWord;
wire rx_VAL, tbr;
wire [11:0] rd_cnt, wr_cnt;
wire [7:0] spart_cap;

SPART_Control spart(
	.clk(clk),
	.rst(rst_n),
	.ctrl(spart_ctrl),
	.rxd(GPIO_0[5]),
	.txd(GPIO_0[3]),
	.sdram_rd_req(spart_req),
	.oWord(rx_data),
	.owordVAL(rx_VAL),
	.iWord(spart_iWord),
	.rd_req_cnt(rd_cnt),
	.wr_req_cnt(wr_cnt),
	.SPART_capture(spart_cap),
	.otbr(tbr)
);

// CCD
wire ccd_en;
wire ccd_done;
wire ccd_dmem_wren;
wire [255:0] ccd_dmem_data;
Image_Proc image_proc(
	.CLOCK2_50(CLOCK2_50),
	.CLOCK_50(CLOCK_50),
	.enable(ccd_en),
	.img_done(ccd_done)
	.dmem_wren(ccd_dmem_wren),
	.dmem_wrdata(ccd_dmem_data)
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
    .data_b(ccd_dmem_data),
    .rden_a(dmem_ren),
    .rden_b(1'b0),
    .wren_a(dmem_wren & ~halt),
    .wren_b(ccd_dmem_wren),
    .q_a(data_to_cpu),
    .q_b()
);