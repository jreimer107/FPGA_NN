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
	output		       D5M_XCLKIN,

	//User controls
	input rst_n,
	input start_key, exposure_key,
	input exposure_sw, zoom_sw,

	// CPU interface
	input enable,
	output img_done,

	// DMEM interface
	output dmem_wren,
	output [6:0] dmem_wraddr,
	output [255:0] dmem_wrdata,

	//SDRAM reset, idk if this is needed
	output oDLY_RST_0
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire		   [15:0]			Read_DATA1;
wire	       [15:0]			Read_DATA2;

wire		   [11:0]			mCCD_DATA;
wire							mCCD_DVAL;
wire							mCCD_DVAL_d;
wire	       [15:0]			X_Cont;
wire	       [15:0]			Y_Cont;
wire	       [9:0]			X_ADDR;
wire	       [31:0]			Frame_Cont;
wire							DLY_RST_0;
wire							DLY_RST_1;
wire							DLY_RST_2;
wire							DLY_RST_3;
wire							DLY_RST_4;
wire							Read;
reg		       [11:0]			rCCD_DATA;
reg								rCCD_LVAL;
reg								rCCD_FVAL;
wire	       [11:0]			sCCD_R;
wire	       [11:0]			sCCD_G;
wire	       [11:0]			sCCD_B;
wire							sCCD_DVAL;

wire	       [9:0]			oVGA_R;   				//	VGA Red[9:0]
wire	       [9:0]			oVGA_G;	 				//	VGA Green[9:0]
wire	       [9:0]			oVGA_B;   				//	VGA Blue[9:0]

//power on start
wire             				auto_start;
//=======================================================
//  Structural coding
//=======================================================

reg start;
always_ff @(posedge CLOCK_50, negedge rst_n)
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
assign oDLY_RST_0 = DLY_RST_0;

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
reg [15:0][15:0] pixels;
assign img_done = pxl_cnt == 783;
always @(posedge CLOCK_50, negedge rst_n)
  	if(!rst_n) begin
		pxl_cnt <= 10'h3FF;
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
