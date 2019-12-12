// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================

//`define ENABLE_HPS
//`define ENABLE_USB

module DE1_SoC_CAMERA(

      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK3 /////////
      input              CLOCK3_50,

      ///////// CLOCK4 /////////
      input              CLOCK4_50,

      ///////// CLOCK /////////
      input              CLOCK_50,

      ///////// DRAM /////////
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

      ///////// GPIO /////////
      inout     [35:0]   GPIO_0,
	
      ///////// HEX0 /////////
      output      [6:0]  HEX0,

      ///////// HEX1 /////////
      output      [6:0]  HEX1,

      ///////// HEX2 /////////
      output      [6:0]  HEX2,

      ///////// HEX3 /////////
      output      [6:0]  HEX3,

      ///////// HEX4 /////////
      output      [6:0]  HEX4,

      ///////// HEX5 /////////
      output      [6:0]  HEX5,

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// SW /////////
      input       [9:0]  SW,

      ///////// VGA /////////
      output      [7:0]  VGA_B,
      output             VGA_BLANK_N,
      output             VGA_CLK,
      output      [7:0]  VGA_G,
      output             VGA_HS,
      output      [7:0]  VGA_R,
      output             VGA_SYNC_N,
      output             VGA_VS,
		
		//////////// GPIO1, GPIO1 connect to D5M - 5M Pixel Camera //////////
	   input		   [11:0] D5M_D,
      input		          D5M_FVAL,
      input		          D5M_LVAL,
      input		          D5M_PIXLCLK,
      output		       D5M_RESET_N,
      output		       D5M_SCLK,
      inout		          D5M_SDATA,
      input		          D5M_STROBE,
      output		       D5M_TRIGGER,
      output		       D5M_XCLKIN
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire			 [15:0]			Read_DATA1;
wire	       [15:0]			Read_DATA2;

wire								DLY_RST_0;
wire								DLY_RST_1;
wire								DLY_RST_2;
wire								DLY_RST_3;
wire								DLY_RST_4;
wire								Read;

wire	       [11:0]			sCCD_R;
wire	       [11:0]			sCCD_G;
wire	       [11:0]			sCCD_B;
wire								sCCD_DVAL;


wire								sdram_ctrl_clk;
wire	       [9:0]			oVGA_R;   				//	VGA Red[9:0]
wire	       [9:0]			oVGA_G;	 				//	VGA Green[9:0]
wire	       [9:0]			oVGA_B;   				//	VGA Blue[9:0]

//power on start
wire             				auto_start;

wire [255:0] ccd_dmem_data;
wire [6:0] ccd_dmem_addr;
wire ccd_dmem_wren;
wire ccd_done;

wire vga_done;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;

wire   VGA_CTRL_CLK = VGA_CLK;

//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(KEY[0]),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						   );

//CPU dmem wires
wire [15:0] cpu_dmem_data;
wire [15:0] cpu_dmem_addr;
wire cpu_dmem_ren, cpu_dmem_wren;

//Accel mock
wire bus_wr;
tri [15:0] databus = bus_wr ? 16'h1234 : 16'hz;
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

wire ccd_en;

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
assign	LEDR = {
	cpu_dmem_ren,
	pc_out[3:0],
	vga_done,
	ccd_done,
	D5M_PIXLCLK,
	pc_advance,
	halt
};
cpu CPU(
    .clk(CLOCK_50),
    .rst_n(KEY[0]),

	//DMEM interface
    .dmem_ren(cpu_dmem_ren), 
    .dmem_wren(cpu_dmem_wren),
	.dmem_addr(cpu_dmem_addr),  
    .dmem_data_to(cpu_dmem_data),
    .dmem_data_from(dmem_q_a),

	// Accel interface
    .accel_done(bus_done),
    // .accel_start(bus_start),
    .accel_en(bus_en),
    .bus_wr(bus_wr),
    .bus_data(databus),
    // .bus_accregaddr(bus_regaddr),

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

wire [10:0] vga_dmem_addr;
wire vga_dmem_ren;
wire [15:0] dmem_q_a;
ram dmem (
	.clock(CLOCK_50),
	
	// CPU/VGA port
	.address_a((cpu_dmem_ren | cpu_dmem_wren) ? cpu_dmem_addr : vga_dmem_addr),
	.data_a(cpu_dmem_data),
	.rden_a(cpu_dmem_ren | vga_dmem_ren),
	.wren_a(cpu_dmem_wren),
	.q_a(dmem_q_a),

	// IPSM/ACCEL port
	.address_b(ccd_dmem_addr),
	.data_b(ccd_dmem_data),
	.rden_b(1'b0),
	.wren_b(ccd_dmem_wren),
	.q_b()
);


wire [11:0] vCCD_DATA;
wire vCCD_DVAL;

BMEM2VGA u4c (
	.iCLK(D5M_PIXLCLK),
	.iRST(DLY_RST_1),

	.iDATA(dmem_q_a),
	.iDONE(ccd_done),

	.oREN(vga_dmem_ren),
	.oADDR(vga_dmem_addr),
	.ovgaDATA(vCCD_DATA),
	.ovgaDVAL(vCCD_DVAL),
	.ovgaDONE(vga_done)
);

assign sCCD_DVAL = vCCD_DVAL;
assign sCCD_R = vCCD_DATA;
assign sCCD_G = vCCD_DATA;
assign sCCD_B = vCCD_DATA;

IPSM ccd(
	.CLOCK2_50(CLOCK2_50),
	.CLOCK_50(CLOCK_50),
	.rst_n(KEY[0]),

	.start_key(!KEY[3]),
	.exposure_key(KEY[1]),
	.exposure_sw(SW[0]),
	.zoom_sw(SW[9]),

	.enable(ccd_en),
	.ccd_done(ccd_done),

	.dmem_wren(ccd_dmem_wren),
	.dmem_wraddr(ccd_dmem_addr),
	.dmem_wrdata(ccd_dmem_data),
	
	.D5M_D(D5M_D),
	.D5M_FVAL(D5M_FVAL),
	.D5M_LVAL(D5M_LVAL),
	.D5M_PIXLCLK(D5M_PIXLCLK),
	.D5M_SCLK(D5M_SCLK),
	.D5M_SDATA(D5M_SDATA)
);

//Frame count display
SEG7_LUT_6 			u5	(	
							.oSEG0(HEX0),.oSEG1(HEX1),
							.oSEG2(HEX2),.oSEG3(HEX3),
							.oSEG4(HEX4),.oSEG5(HEX5),
							.iDIG(seg7_output)
						   );
												
sdram_pll 			u6	(
							.refclk(CLOCK_50),
							.rst(1'b0),
							.outclk_0(sdram_ctrl_clk),
							.outclk_1(DRAM_CLK),
							.outclk_2(D5M_XCLKIN),    //25M
					      	.outclk_3(VGA_CLK)       //25M

						   );



//SDRam Read and Write as Frame Buffer
Sdram_Control	   u7	(	//	HOST Side						
						   	.RESET_N(KEY[0]),
							.CLK(sdram_ctrl_clk),

							//	FIFO Write Side 1
							.WR1_DATA({1'b0,sCCD_G[11:7],sCCD_B[11:2]}),
							.WR1(sCCD_DVAL),
							.WR1_ADDR(0),
                     		.WR1_MAX_ADDR(640*480),
						   	.WR1_LENGTH(8'h50),
		               		.WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(~D5M_PIXLCLK),

							//	FIFO Write Side 2
							.WR2_DATA({1'b0,sCCD_G[6:2],sCCD_R[11:2]}),
							.WR2(sCCD_DVAL),
							.WR2_ADDR(23'h100000),
							.WR2_MAX_ADDR(23'h100000+640*480),
							.WR2_LENGTH(8'h50),
							.WR2_LOAD(!DLY_RST_0),				
							.WR2_CLK(~D5M_PIXLCLK),

                     //	FIFO Read Side 1
						   	.RD1_DATA(Read_DATA1),
				        	.RD1(Read),
				        	.RD1_ADDR(0),
                     		.RD1_MAX_ADDR(640*480),
							.RD1_LENGTH(8'h50),
							.RD1_LOAD(!DLY_RST_0),
							.RD1_CLK(~VGA_CTRL_CLK),
							
							//	FIFO Read Side 2
						   	.RD2_DATA(Read_DATA2),
							.RD2(Read),
							.RD2_ADDR(23'h100000),
                     		.RD2_MAX_ADDR(23'h100000+640*480),
							.RD2_LENGTH(8'h50),
                   			.RD2_LOAD(!DLY_RST_0),
							.RD2_CLK(~VGA_CTRL_CLK),
										
							//	SDRAM Side
						   	.SA(DRAM_ADDR),
							.BA(DRAM_BA),
							.CS_N(DRAM_CS_N),
							.CKE(DRAM_CKE),
							.RAS_N(DRAM_RAS_N),
							.CAS_N(DRAM_CAS_N),
							.WE_N(DRAM_WE_N),
							.DQ(DRAM_DQ),
							.DQM({DRAM_UDQM,DRAM_LDQM})
						   );
							
//VGA DISPLAY
VGA_Controller	  u1	(	//	Host Side
							.oRequest(Read),
							.iRed(Read_DATA2[9:0]),
					      	.iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
						   	.iBlue(Read_DATA1[9:0]),
						
							//	VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC_N),
							.oVGA_BLANK(VGA_BLANK_N),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST_2),
							.iZOOM_MODE_SW(SW[9])
						   );
endmodule
