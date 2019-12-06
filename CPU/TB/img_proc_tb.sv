module img_proc_tb();
reg CLOCK_50,
reg CLOCK2_50,
	
//////////// GPIO1, GPIO1 connect to D5M - 5M Pixel Camera //////////
reg		   [11:0] D5M_D,
reg		          D5M_FVAL,
reg		          D5M_LVAL,
reg		          D5M_PIXLCLK,
wire		          D5M_RESET_N,
wire		          D5M_SCLK,
tri		          D5M_SDATA,
wire		          D5M_TRIGGER,

//User controls
reg rst_n,
reg start_key, exposure_key,
reg exposure_sw, zoom_sw,

// CPU interface
reg enable,
wire ccd_done,

// DMEM interface
wire dmem_wren,
wire [6:0] dmem_wraddr,
wire [255:0] dmem_wrdata,

//SDRAM reset, idk if this is needed
wire oDLY_RST_0,

wire [9:0] pxl_cnt;
wire start_cap;

assign D5M_PIXLCLK = D5M_SCLK;
assign D5M_

Image_Proc DUT(
	.CLOCK_50(clk),
	.CLOCK2_50(clk),
	.rst_n(rst_n),

	// GPIO1
	.D5M_D(D5M_D),
	.D5M_FVAL(D5M_FVAL),
	.D5M_LVAL(D5M_LVAL),
	.D5M_PIXLCLK(D5M_PIXLCLK),
	.D5M_RESET_N(D5M_RESET_N),
	.D5M_SCLK(D5M_SCLK),
	.D5M_SDATA(D5M_SDATA),
	.D5M_TRIGGER(D5M_TRIGGER),

	//User controls
	.start_key(start_key),
	.exposure_key(exposure_key),
	.exposure_sw(exposure_sw),
	.zoom_sw(zoom_sw),

	//CPU interface
	.enable(enable),
	.ccd_done(ccd_done),
	
	//DMEM interface
	.dmem_wren(dmem_wren),
	.dmem_wraddr(dmem_wraddr),
	.dmem_wrdata(dmem_wrdata),
	
	// Stupid sdram reset
	.oDLY_RST_0(oDLY_RST_0),
	
	// Debug Signals
	.pxl_cnt(pxl_cnt),
	.start_cap(start_cap)
);


initial begin
	rst_n = 0;
	clk = 0;
	start_key = 0;
	exposure_key = 0;
	exposure_sw = 0;
	zoom_sw = 0;
	enable = 0;
	
	@(negedge clk);
	rst_n = 1;
	
	repeat(3) @(posedge clk);
	enable = 1;
	repeat(3) @(posedge clk);
	start_key = 1;
	repeat(3) @(negedge clk) 
	start_key = 0;





end


always
	#10 clk = ~clk;


endmodule