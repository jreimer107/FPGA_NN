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
	output		       D5M_XCLKIN,

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
wire [6:0] ccd_dmem_addr;
wire [255:0] ccd_dmem_data;
wire DLY_RST_0;
wire [9:0] pxl_cnt;
wire ccd_start_cap;
Image_Proc image_proc(
	.CLOCK2_50(CLOCK2_50),
	.CLOCK_50(CLOCK_50),
	.rst_n(rst_n),

	// User controls
	.start_key(!KEY[3]),
	.exposure_key(!KEY[2]),
	.exposure_sw(SW[7]),
	.zoom_sw(SW[6]),

	// CPU interface
	.enable(ccd_en),
	.ccd_done(ccd_done),

	// DMEM interface
	.dmem_wren(ccd_dmem_wren),
	.dmem_wraddr(ccd_dmem_addr),
	.dmem_wrdata(ccd_dmem_data),

	// //VGA
	// .VGA_B(VGA_B),
	// .VGA_BLANK_N(VGA_BLANK_N),
	// .VGA_CLK(VGA_CLK),
	// .VGA_G(VGA_G),
	// .VGA_HS(VGA_HS),
	// .VGA_R(VGA_R),
	// .VGA_SYNC_N(VGA_SYNC_N),
	// .VGA_VS(VGA_VS),

	//GPIO1
	.D5M_D(D5M_D),
	.D5M_FVAL(D5M_FVAL),
	.D5M_LVAL(D5M_LVAL),
	.D5M_PIXLCLK(D5M_PIXLCLK),
	.D5M_RESET_N(D5M_RESET_N),
	.D5M_SCLK(D5M_SCLK),
	.D5M_SDATA(D5M_SDATA),
	.D5M_STROBE(D5M_STROBE),
	.D5M_TRIGGER(D5M_TRIGGER),
	// .D5M_XCLKIN(D5M_XCLKIN),

	//Stupid sdram reset
	.oDLY_RST_0(DLY_RST_0),

	.pxl_cnt(pxl_cnt),
	//.start_cap(ccd_start_cap)
);

//CPU dmem wires
wire [15:0] cpu_dmem_data, dmem_cpu_data;
wire [15:0] cpu_dmem_addr;
wire cpu_dmem_ren, cpu_dmem_wren;

//Accel mock
wire [1:0] bus_rdwr;
tri [15:0] databus = bus_rdwr[1] ? 16'h1234 : 16'hz;
wire bus_en;
wire bus_start;
wire [2:0] bus_regaddr;
wire bus_done = bus_en & bus_start;

// CPU debug
wire [15:0] pc_out, reg_out;
wire halt;
wire [23:0] instr_out;
reg [23:0] seg7_output;
reg pc_advance;
reg key_last;
always @(posedge CLOCK_50) begin
	// PC Advance
	key_last <= KEY[1];
	if (SW[9])
		pc_advance <= key_last & !KEY[1];
	else
		pc_advance <= 1'b1;

	// Seg7 output
	if (SW[8])
		seg7_output <= instr_out;
	else
		seg7_output <= {8'h0, reg_out};
end
assign	LEDR = {pc_out[4:0], 1'b0, ccd_done, ccd_en, pc_advance, halt};

SEG7_LUT_6 u5 (	
	.oSEG0(HEX0),.oSEG1(HEX1),
	.oSEG2(HEX2),.oSEG3(HEX3),
	.oSEG4(HEX4),.oSEG5(HEX5),
	.iDIG({14'b0, pxl_cnt})
);

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

	// Debug signals
    .halt(halt),
    .pc_out(pc_out),
    .reg_index(SW[3:0]),
    .reg_out(reg_out),
    .pc_advance(pc_advance),
    .instr_out(instr_out)
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


// wire sdram_ctrl_clk;
// sdram_pll u6	(
// 	.refclk(CLOCK_50),
// 	.rst(rst_n),
// 	.outclk_0(sdram_ctrl_clk),
// 	.outclk_1(DRAM_CLK),
// 	.outclk_2(D5M_XCLKIN),    //25M
// 	.outclk_3(VGA_CLK)       //25M
// );

// // SDRAM Controller for Weights
// // SDRam Read and Write as Frame Buffer
// Sdram_Control u7 (
// 	//	HOST Side						
// 	.RESET_N(rst_n),
// 	.CLK(sdram_ctrl_clk),

// 	//	FIFO Write Side 1
// 	.WR1_DATA(rx_data),
// 	.WR1(rx_VAL),
// 	.WR1_ADDR(0),
// 	.WR1_MAX_ADDR(23'd8),
// 	.WR1_LENGTH(8'h01),
// 	.WR1_LOAD(!DLY_RST_0),
// 	.WR1_CLK(~CLOCK_50),

// 	//	FIFO Read Side 1
// 	.RD1_DATA(Read_txDATA),
// 	.RD1(sdram_rd_req),
// 	.RD1_ADDR(0),
// 	.RD1_MAX_ADDR(23'd8),
// 	.RD1_LENGTH(8'h01),
// 	.RD1_LOAD(!DLY_RST_0),
// 	.RD1_CLK(~CLOCK_50),

// 	.DATA_VAL(),
// 	.DQ_Sample(dq),
// 	.led_out(sdram_leds),

// 	//	FIFO Write Side 2
// 	.WR2_DATA(),
// 	.WR2(),
// 	.WR2_ADDR(23'h100000),
// 	.WR2_MAX_ADDR(23'h100000),
// 	.WR2_LENGTH(8'h00),
// 	.WR2_LOAD(!DLY_RST_0),
// 	.WR2_CLK(~sdram_ctrl_clk),

// 	//	FIFO Read Side 2
// 	.RD2_DATA(),
// 	.RD2(),
// 	.RD2_ADDR(23'h100000),
// 	.RD2_MAX_ADDR(23'h100000),
// 	.RD2_LENGTH(8'h00),
// 	.RD2_LOAD(!DLY_RST_0),
// 	.RD2_CLK(~sdram_ctrl_clk),

// 	//	SDRAM Side
// 	.SA(DRAM_ADDR),
// 	.BA(DRAM_BA),
// 	.CS_N(DRAM_CS_N),
// 	.CKE(DRAM_CKE),
// 	.RAS_N(DRAM_RAS_N),
// 	.CAS_N(DRAM_CAS_N),
// 	.WE_N(DRAM_WE_N),
// 	.DQ(DRAM_DQ),
// 	.DQM({DRAM_UDQM,DRAM_LDQM})
// );
endmodule