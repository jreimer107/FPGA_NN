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


module Image_Proc(

	  ///////// ADC /////////
	//   inout              ADC_CS_N,
	//   output             ADC_DIN,
	//   input              ADC_DOUT,
	//   output             ADC_SCLK,

	  ///////// AUD /////////
	//   input              AUD_ADCDAT,
	//   inout              AUD_ADCLRCK,
	//   inout              AUD_BCLK,
	//   output             AUD_DACDAT,
	//   inout              AUD_DACLRCK,
	//   output             AUD_XCK,

	  ///////// CLOCK2 /////////
	  input              CLOCK2_50,

	  ///////// CLOCK3 /////////
	//   input              CLOCK3_50,

	  ///////// CLOCK4 /////////
	//   input              CLOCK4_50,

	  ///////// CLOCK /////////
	  input              CLOCK_50,

	  ///////// DRAM /////////
	//   output      [12:0] DRAM_ADDR,
	//   output      [1:0]  DRAM_BA,
	//   output             DRAM_CAS_N,
	//   output             DRAM_CKE,
	//   output             DRAM_CLK,
	//   output             DRAM_CS_N,
	//   inout       [15:0] DRAM_DQ,
	//   output             DRAM_LDQM,
	//   output             DRAM_RAS_N,
	//   output             DRAM_UDQM,
	//   output             DRAM_WE_N,

	  ///////// FAN /////////
	//   output             FAN_CTRL,

	  ///////// FPGA /////////
	//   output             FPGA_I2C_SCLK,
	//   inout              FPGA_I2C_SDAT,

	//   ///////// GPIO /////////
	//   inout     [35:0]   GPIO_0,
	
	//   ///////// HEX0 /////////
	//   output      [6:0]  HEX0,

	//   ///////// HEX1 /////////
	//   output      [6:0]  HEX1,

	//   ///////// HEX2 /////////
	//   output      [6:0]  HEX2,

	//   ///////// HEX3 /////////
	//   output      [6:0]  HEX3,

	//   ///////// HEX4 /////////
	//   output      [6:0]  HEX4,

	//   ///////// HEX5 /////////
	//   output      [6:0]  HEX5,

	  ///////// IRDA /////////
	//   input              IRDA_RXD,
	//   output             IRDA_TXD,

	//   ///////// KEY /////////
	//   input       [3:0]  KEY,

	//   ///////// LEDR /////////
	//   output      [9:0]  LEDR,

	  ///////// PS2 /////////
	//   inout              PS2_CLK,
	//   inout              PS2_CLK2,
	//   inout              PS2_DAT,
	//   inout              PS2_DAT2,

	  ///////// SW /////////
	//   input       [9:0]  SW,

	  ///////// TD /////////
	//   input              TD_CLK27,
	//   input      [7:0]   TD_DATA,
	//   input              TD_HS,
	//   output             TD_RESET_N,
	//   input              TD_VS,

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

	input rst_n,
	input enable,
	input start_key, exposure_key,
	input exposure_sw, zoom_sw,
	output img_done
	output dmem_wren;
	output [6:0] dmem_wraddr;
	output [255:0] dmem_wrdata;
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire			 [15:0]			Read_DATA1;
wire	       [15:0]			Read_DATA2;

wire			 [11:0]			mCCD_DATA;
wire								mCCD_DVAL;
wire								mCCD_DVAL_d;
wire	       [15:0]			X_Cont;
wire	       [15:0]			Y_Cont;
wire	       [9:0]			X_ADDR;
wire	       [31:0]			Frame_Cont;
wire								DLY_RST_0;
wire								DLY_RST_1;
wire								DLY_RST_2;
wire								DLY_RST_3;
wire								DLY_RST_4;
wire								Read;
reg		    [11:0]			rCCD_DATA;
reg								rCCD_LVAL;
reg								rCCD_FVAL;
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
//=======================================================
//  Structural coding
//=======================================================

reg start;
always_ff(@posedge CLOCK_50, negedge rst_n)
	if (!rst_n)
		start <= 0;
	else 
		if (!start_cap & enable & start_key)
			start <= 1;
		else
			start <= 0;


// One image captured per enable cycle
reg start_cap, captured;
always @(posedge CLOCK_50, negedge rst_n) begin
  if (!rst_n)
	start_cap <= 0;
  else if (captured)
	start_cap <= 0;
  else if (start)
	start_cap <= 1;
end
always @(posedge CLOCK_50, negedge rst_n) begin
  if (!rst_n)
	captured <= 0;
  else if (start)
	captured <= 0;
  else if(D5M_FVAL == 1 && start_cap)//else if(D5M_FVAL == 1 && KEY[2] == 0)
	captured <= 1;
end

// D5M
assign	D5M_TRIGGER	=	!enable || captured;//KEY[2] || (newF && ~KEY[2]);//cap;//KEY[2] | newF;// && allow_cap;//capture;//1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;

assign   VGA_CTRL_CLK = VGA_CLK;


//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
	rCCD_DATA	<=	D5M_D;
	rCCD_LVAL	<=	D5M_LVAL;
	rCCD_FVAL	<=	D5M_FVAL;
end


//auto start when power on
assign auto_start = rst_n & DLY_RST_3 & !DLY_RST_4 & start_cap & !captured;
//Reset module
Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(rst_n),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						   );
//D5M image capture
CCD_Capture			u3	(	
							.oDATA(mCCD_DATA),
							.oDVAL(mCCD_DVAL),
							.oX_Cont(X_Cont),
							.oY_Cont(Y_Cont),
							.oFrame_Cont(Frame_Cont),
							.iDATA(rCCD_DATA),
							.iFVAL(rCCD_FVAL),
							.iLVAL(rCCD_LVAL),
							.iSTART(auto_start),
							.iEND(1'b0),
							.iCLK(~D5M_PIXLCLK),
							.iRST(DLY_RST_2)
						   );

//D5M raw date convert to RGB data
// wire [23:0] sample;
wire[8:0] norm_pxl;
RAW2RGB				u4	(	
							.iCLK(D5M_PIXLCLK),
							.iRST(DLY_RST_1),
							.iDATA(mCCD_DATA),
							.iDVAL(mCCD_DVAL),
							.oRed(sCCD_R),
							.oGreen(sCCD_G),
							.oBlue(sCCD_B),
							.oDVAL(sCCD_DVAL),
							.iX_Cont(X_Cont),
							.iY_Cont(Y_Cont),
							.iCTRL(2'h3),
							.cd_buf_rst(start),
							// .oSC(sample),
							.oPxl(norm_pxl)
						   );
// wire data_val;


reg [9:0] pxl_cnt;
reg [15:0] pixels [15:0];
assign img_done = pxl_cnt == 783;
always @(posedge CLOCK_50, negedge rst_n)
  	if(!rst) begin
		pxl_cnt <= 10'h3FF;
		img_done <= 0;
		dmem_wren <= 0;
		dmem_wraddr <= -1;
	end
  	else begin
		dmem_wren <= 0;
		pxl_cnt <= pxl_cnt;
		dmem_wraddr <= dmem_wraddr;
		if (sCCD_DVAL) begin
			if (img_done) begin
				pxl_cnt <= 0;
				dmem_wren <= enable;
				dmem_wraddr <= -1;
			end
			else begin
				pixels[pxl_cnt % 16] <= {8'h0, norm_pxl};
				pxl_cnt <= pxl_cnt + 1;
			end
			if (pxl_cnt % 16 == 0 && enable) begin
				dmem_wren <= 1'b1;
				dmem_wraddr <= dmem_wraddr + 1;
			end
		end
	end

assign dmem_wrdata = pixels;
											
sdram_pll 			u6	(
							.refclk(CLOCK_50),
							.rst(1'b0),
							.outclk_0(sdram_ctrl_clk),
							.outclk_1(DRAM_CLK),
							.outclk_2(D5M_XCLKIN),    //25M
						  .outclk_3(VGA_CLK)       //25M

						   );

// SDRAM Controller for Weights
//SDRam Read and Write as Frame Buffer
Sdram_Control u7 (
			//	HOST Side						
			.RESET_N(rst_n),
			.CLK(sdram_ctrl_clk),

			//	FIFO Write Side 1
			.WR1_DATA(rx_data),
			.WR1(rx_VAL),//.WR1(flop_wr_req),//
			.WR1_ADDR(0),//.WR1_ADDR(wr_addr),//
			.WR1_MAX_ADDR(max_addr),//.WR1_MAX_ADDR(max_addr),//
			.WR1_LENGTH(8'h01),
			.WR1_LOAD(!DLY_RST_0),
			.WR1_CLK(~CLOCK_50),

			//	FIFO Read Side 1
			.RD1_DATA(Read_txDATA),
			.RD1(sdram_rd_req),//.RD1(flop_rd_req),//
			.RD1_ADDR(0),//.RD1_ADDR(rd_addr),//
			.RD1_MAX_ADDR(max_addr),//.RD1_MAX_ADDR(max_addr),//
			.RD1_LENGTH(8'h01),
			.RD1_LOAD(!DLY_RST_0),
			.RD1_CLK(~CLOCK_50),

			.DATA_VAL(),
			.DQ_Sample(dq),
			.led_out(sdram_leds),

			//	FIFO Write Side 2
			.WR2_DATA(),
			.WR2(),
			.WR2_ADDR(23'h100000),
			.WR2_MAX_ADDR(23'h100000),
			.WR2_LENGTH(8'h00),
			.WR2_LOAD(!DLY_RST_0),
			.WR2_CLK(~sdram_ctrl_clk),

			//	FIFO Read Side 2
			.RD2_DATA(),
			.RD2(),
			.RD2_ADDR(23'h100000),
			.RD2_MAX_ADDR(23'h100000),
			.RD2_LENGTH(8'h00),
			.RD2_LOAD(!DLY_RST_0),
			.RD2_CLK(~sdram_ctrl_clk),

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
			
//D5M I2C control
I2C_CCD_Config 	u8	(	//	Host Side
							.iCLK(CLOCK2_50),
							.iRST_N(DLY_RST_2),
							.iEXPOSURE_ADJ(exposure_key),
							.iEXPOSURE_DEC_p(exposure_sw),
							.iZOOM_MODE_SW(zoom_sw),
							//	I2C Side
							.I2C_SCLK(D5M_SCLK),
							.I2C_SDAT(D5M_SDATA)
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
							.iZOOM_MODE_SW(zoom_sw)
						   );

endmodule
