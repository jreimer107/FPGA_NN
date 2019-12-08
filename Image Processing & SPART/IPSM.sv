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

module IPSM(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK_50,
    input rst_n,

    //User inputs
    input start_key, exposure_key,
	input exposure_sw, zoom_sw,

    // CPU interface
	input enable,
	output reg ccd_done,

	// DMEM interface
	output reg dmem_wren,
	output reg [6:0] dmem_wraddr,
	output reg [255:0] dmem_wrdata,

	//////////// GPIO_1, GPIO_1 connect to D5M - 5M Pixel Camera //////////
	input 		    [11:0]		D5M_D,
	input 		          		D5M_FVAL,
	input 		          		D5M_LVAL,
	input 		          		D5M_PIXLCLK,
	output		          		D5M_RESET_N,
	output		          		D5M_SCLK,
	inout 		          		D5M_SDATA,
	input 		          		D5M_STROBE,
	output		          		D5M_TRIGGER,
	output		          		D5M_XCLKIN
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire						    DLY_RST_0;
wire						    DLY_RST_1;
wire						    DLY_RST_2;
wire						    DLY_RST_3;
wire						    DLY_RST_4;

// Pipeline stages
reg		        [11:0]			rCCD_DATA;
reg								rCCD_LVAL;
reg								rCCD_FVAL;

wire		    [11:0]			mCCD_DATA;
wire							mCCD_DVAL;
wire	        [15:0]			X_Cont;
wire	        [15:0]			Y_Cont;
wire	        [31:0]			Frame_Cont;

wire	        [11:0]			dCCD_DATA;
wire							dCCD_DVAL;
wire            [15:0]           X_Gray;
wire            [15:0]           Y_Gray;

wire	        [11:0]			sCCD_DATA;
wire							sCCD_DVAL;


//power on start
wire             				auto_start;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
	rCCD_DATA	<=	D5M_D;
	rCCD_LVAL	<=	D5M_LVAL;
	rCCD_FVAL	<=	D5M_FVAL;
end


//auto start when power on
assign auto_start = ((rst_n)&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;

//Reset module
Reset_Delay u2 (	
    .iCLK(CLOCK_50),
    .iRST(rst_n),

    .oRST_0(DLY_RST_0),
    .oRST_1(DLY_RST_1),
    .oRST_2(DLY_RST_2),
    .oRST_3(DLY_RST_3),
    .oRST_4(DLY_RST_4)
);

/// Image Capture Pipeline ///
//D5M image capture
CCD_Capture	u3 (
    .iCLK(~D5M_PIXLCLK),
    .iRST(DLY_RST_2),

    .iSTART(start_key|auto_start),
    .iEND(1'b0),
    .iFVAL(rCCD_FVAL),
    .iLVAL(rCCD_LVAL),
    .iDATA(rCCD_DATA),

    .oDATA(mCCD_DATA),
    .oDVAL(mCCD_DVAL),
    .oX_Cont(X_Cont),
    .oY_Cont(Y_Cont),
    .oFrame_Cont(Frame_Cont)
);

//D5M raw date convert to grayscale data
RAW2GRAY u4 (	
    .iCLK(D5M_PIXLCLK),
    .iRST(DLY_RST_1),

    .iDATA(mCCD_DATA),
    .iDVAL(mCCD_DVAL),
    .iX_Cont(X_Cont),
    .iY_Cont(Y_Cont),

    .oDATA(dCCD_DATA),
    .oDVAL(dCCD_DVAL),
    .oX(X_Gray),
    .oY(Y_Gray)
);

//D5M sample image down to 28x28 image
CropDown u5 (
	.iCLK(D5M_PIXLCLK), 
	.iRST(DLY_RST_1),

	.iDVAL(dCCD_DVAL), 
	.iDATA(dCCD_DATA), 
	.iX(X_Gray[10:1]),
	.iY(Y_Gray[10:1]),
    
	.oDATA(sCCD_DATA),
	.oDVAL(sCCD_DVAL)
);
/// End Image Capture Pipeline ///

// Control image capture and storage	
Img_Proc_FSM FSM (
	.clk(CLOCK_50),
	.pxlclk(D5M_PIXLCLK),
	.rst_n(rst_n),

	// CPU interface
	.enable(enable),
	.oCCD_Done(ccd_done)

	// User control
	.iStart(start_key),
	
	// Pipeline interface
	.iFVAL(D5M_FVAL),
	.iDVAL(sCCD_DVAL),
	.iDATA(sCCD_DATA),

	// Bmem 256-bit write port
	.oDmem_wren(dmem_wren),
	.oDmem_addr(dmem_wraddr),
	.oDmem_data(dmem_wrdata),

);

//D5M I2C control
I2C_CCD_Config u8 (	
    //	Host Side
    .iCLK(CLOCK2_50),
    .iRST_N(DLY_RST_2),
    .iEXPOSURE_ADJ(exposure_key),
    .iEXPOSURE_DEC_p(exposure_sw),
    .iZOOM_MODE_SW(zoom_sw),
    //	I2C Side
    .I2C_SCLK(D5M_SCLK),
    .I2C_SDAT(D5M_SDATA)
);

endmodule
