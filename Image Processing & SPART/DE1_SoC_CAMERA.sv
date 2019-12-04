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

      ///////// ADC /////////
      inout              ADC_CS_N,
      output             ADC_DIN,
      input              ADC_DOUT,
      output             ADC_SCLK,

      ///////// AUD /////////
      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output             AUD_DACDAT,
      inout              AUD_DACLRCK,
      output             AUD_XCK,

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

      ///////// FAN /////////
      output             FAN_CTRL,

      ///////// FPGA /////////
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,

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

`ifdef ENABLE_HPS
      ///////// HPS /////////
      input              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/

      ///////// IRDA /////////
      input              IRDA_RXD,
      output             IRDA_TXD,

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// PS2 /////////
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,

      ///////// SW /////////
      input       [9:0]  SW,

      ///////// TD /////////
      input              TD_CLK27,
      input      [7:0]   TD_DATA,
      input              TD_HS,
      output             TD_RESET_N,
      input              TD_VS,

`ifdef ENABLE_USB
      ///////// USB /////////
      input              USB_B2_CLK,
      inout       [7:0]  USB_B2_DATA,
      output             USB_EMPTY,
      output             USB_FULL,
      input              USB_OE_N,
      input              USB_RD_N,
      input              USB_RESET_N,
      inout              USB_SCL,
      inout              USB_SDA,
      input              USB_WR_N,
`endif /*ENABLE_USB*/

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

reg start_cap, captured;
always @(posedge CLOCK_50, negedge KEY[0]) begin
  if(!KEY[0])
    start_cap <= 0;
  else if(!KEY[3])
    start_cap <= 0;
  else if(KEY[2] == 0)
    start_cap <= 1;
end
always @(posedge CLOCK_50, negedge KEY[0]) begin
  if(!KEY[0])
    captured <= 0;
  else if(!KEY[3])
    captured <= 0;
  else if(D5M_FVAL == 1 && start_cap)//else if(D5M_FVAL == 1 && KEY[2] == 0)
    captured <= 1;
end

// D5M
assign	D5M_TRIGGER	=	KEY[2] || captured;//KEY[2] || (newF && ~KEY[2]);//cap;//KEY[2] | newF;// && allow_cap;//capture;//1'b1;  // tRIGGER
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
assign auto_start = ((KEY[0])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
//Reset module
Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(KEY[0]),
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
							.iSTART(auto_start),//.iSTART(!KEY[3]|auto_start),
							.iEND(),//.iEND(KEY[3]),//.iEND(!KEY[2]),
							.iCLK(~D5M_PIXLCLK),
							.iRST(DLY_RST_2)
						   );
//D5M raw date convert to RGB data
wire [23:0] sample;
wire [10:0] BRAM_bWR_ADDR;
wire [15:0] BRAM_bWR_DATA;
wire BRAM_bWR_EN;

wire img_done;
wire [783:0][15:0] img;

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
							.iCTRL({SW[2:1]}),
							.cd_buf_rst(!KEY[3]),
							.oSC(sample),
							.img_done(img_done),
							.img(img)
						   );
reg [31:0] rd_outputs, dv_cnt;
wire [15:0] rx_data, Read_txDATA;
reg [15:0] tx_out;
wire rx_VAL, spart_req, data_val;

reg [15:0] prev_data;
always @(posedge CLOCK_50, negedge KEY[0])
  if(!KEY[0])
    prev_data <= 0;
  else
    prev_data <= Read_txDATA;

always @(posedge CLOCK_50, negedge KEY[0])
  if(!KEY[0])
    tx_out <= 0;
  else if(Read_txDATA != prev_data)
    tx_out <= Read_txDATA;

wire [11:0] rd_cnt,wr_cnt;
wire [7:0] spart_cap;

reg [7:0] val_cnt;
always @(posedge CLOCK_50, negedge KEY[0])
  if(!KEY[0])
    val_cnt <= 0;
  else if(Read_txDATA != prev_data)
    val_cnt <= val_cnt + 1;

wire tbr;

wire [22:0] max_addr;
assign max_addr = 23'd1;//238200;

wire [22:0] spart_max_words;
assign spart_max_words = SW[8] ? 784 : max_addr;

wire [15:0] q_a;	// Data from BRAM read
wire [15:0] img_pxl;
wire [15:0] spart_iWord;
assign spart_iWord = SW[8] ? img_pxl : Read_txDATA;

wire sdram_rd_req;
assign sdram_rd_req = SW[8] ? 0 : spart_req;

wire bram_rd_req;	// BRAM read request
assign bram_rd_req = SW[8] ? spart_req : 0;

reg start_display;
always @(posedge CLOCK_50, negedge KEY[0])
  if(!KEY[0])
    start_display <= 0;
  else if(img_done)
    start_display <= 1;

reg [9:0] idx;
always @(posedge CLOCK_50, negedge KEY[0])
  if(!KEY[0])
    idx <= 10'h3FF;
  else if(spart_req && start_display && SW[8])//else if(&temp_cnt)
    if(idx == 783)
      idx <= 0;
    else
      idx <= idx + 1;

assign img_pxl = idx <= 783 ?
			img[idx] > 16'h007F ? 16'h3333 :
			img[idx] > 16'h000F ? 16'h3232 :
			img[idx] > 16'h0007 ? 16'h3131 :
			16'h3030 
		 : 0;


SPART_Control	spart(	.clk(CLOCK_50),
			.rst(!KEY[0]),
			.ctrl({!KEY[3],2'b00}),//.ctrl(SW[7:5]),
			.rxd(GPIO_0[5]),
			.txd(GPIO_0[3]),
			.rd_req(spart_req),
			.oWord(rx_data),
			.owordVAL(rx_VAL),
			.iWord(spart_iWord),
			.max_words(spart_max_words),
			.rd_req_cnt(rd_cnt),
			.wr_req_cnt(wr_cnt),
			.SPART_capture(spart_cap),
			.otbr(tbr)
		);

wire [15:0] dq;
wire [1:0] sdram_leds;

assign	LEDR		=	{(Read_txDATA==dq),sdram_leds,3'b0,start_display,tbr,captured,KEY[0]};//Y_Cont;


//Frame count display
SEG7_LUT_6 			u5	(	
							.oSEG0(HEX0),.oSEG1(HEX1),
							.oSEG2(HEX2),.oSEG3(HEX3),
							.oSEG4(HEX4),.oSEG5(HEX5),
							.iDIG({wr_cnt[7:0],rx_data})//.iDIG({rd_cnt[3:0],wr_cnt[3:0],spart_cap[3:0],tx_out[3:0],Read_txDATA[3:0],val_cnt[3:0]})//.iDIG({rd_cnt[3:0],wr_cnt[3:0],4'b0,Read_txDATA[11:8],tx_out[3:0],spart_cap[3:0]})//.iDIG({Read_txDATA[15:8],dq})//.iDIG({Read_txDATA[15:8],rx_data[15:8],tx_out[15:8]})//.iDIG({rx_data[15:8],Read_txDATA})//.iDIG({8'b0,rx_data})//.iDIG(sample)//.iDIG(Frame_Cont[23:0])
						   );
												
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
			.RESET_N(KEY[0]),
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

			.DATA_VAL(data_val),
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

wire [10:0] img_addr, address_a;
assign img_base_addr = 0;
assign address_a = SW[8] ? rd_cnt : img_base_addr + BRAM_bWR_ADDR; 

/*ram bram(
//	.address_a(address_a),
//	.address_b(),
	.clock(CLOCK_50),
	.data_a(BRAM_bWR_DATA),
	.data_b(),
	.rden_a(bram_rd_req),
	.rden_b(0),
	.wren_a(0),
	.wren_b(BRAM_bWR_EN),
	.q_a(q_a),
	.q_b()
	);
*/

/*
// SDRAM Controller for VGA output
//SDRam Read and Write as Frame Buffer
Sdram_Control u7 (
			//	HOST Side						
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
*/							
				
//D5M I2C control
I2C_CCD_Config 	u8	(	//	Host Side
							.iCLK(CLOCK2_50),
							.iRST_N(DLY_RST_2),
							.iEXPOSURE_ADJ(KEY[1]),
							.iEXPOSURE_DEC_p(SW[0]),
							.iZOOM_MODE_SW(SW[9]),
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
							.iZOOM_MODE_SW(SW[9])
						   );

endmodule