// --------------------------------------------------------------------
// Copyright (c) 20057 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
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
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	RAW2RGB
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| 		Changes Made:
//   V1.0 :| Johnny Fan        :| 07/08/01  :|      Initial Revision
// --------------------------------------------------------------------

module RAW2RGB(	oRed,
				oGreen,
				oBlue,
				oDVAL,
				iX_Cont,
				iY_Cont,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
				iCTRL,
				cd_buf_rst,
				oSC,
				img_done,
				img
				);

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
input	[1:0]	iCTRL;
input cd_buf_rst;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;
output [23:0] oSC;
output img_done;
output [783:0][15:0] img;

wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;
reg		[11:0]	mCCD_R;
reg		[12:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg				mDVAL;

wire sr_oDVAL, RGB_oDVAL;

// Grayscale value is average of four RGB values
wire [11:0] gray, o_data;
assign gray = (mCCD_R[11:0] + mCCD_G[12:0] + mCCD_B[11:0]) / 4;

/*
// Convoltution handler
Shift_Register sr(.iCLK(iCLK), 
				.iRST(iRST), 
				.iDVAL(RGB_oDVAL), 
				.grayVal(gray), 
				.oDVAL(sr_oDVAL), 
				.oDATA(o_data), 
				.iX(iX_Cont[10:1]), 
				.iY(iY_Cont[10:1]), 
				.iFilter(iCTRL[2])	);
*/


CropDown cds(	.iCLK(iCLK), 
		.iRST(iRST), 
		.buf_rst(cd_buf_rst),
		.iDVAL(RGB_oDVAL), 
		.grayVal(gray), 
		.oDVAL(sr_oDVAL), 
		.oDATA(o_data), 
		.iY(iY_Cont[10:1]),
		.oSC(oSC),
		.img(img),
		.done(img_done)
	    );

/*
CropDownMean cdm(	.iCLK(iCLK), 
		.iRST(iRST), 
		.buf_rst(cd_buf_rst),
		.iDVAL(RGB_oDVAL), 
		.grayVal(gray), 
		.oDVAL(sr_oDVAL), 
		.oDATA(o_data), 
		.iY(iY_Cont[10:1]),
		.oSC(oSC)
	    );
*/

// Assign RGB outputs based on switch inputs
assign	oRed	=	iCTRL[1] ? o_data : iCTRL[0] ? gray : mCCD_R[11:0];
assign	oGreen	=	iCTRL[1] ? o_data : iCTRL[0] ? gray : mCCD_G[12:1];
assign	oBlue	=	iCTRL[1] ? o_data : iCTRL[0] ? gray : mCCD_B[11:0];
assign RGB_oDVAL = mDVAL;
assign	oDVAL	=	iCTRL[1] ? sr_oDVAL : RGB_oDVAL;

Line_Buffer1 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_R	<=	0;
		mCCD_G	<=	0;
		mCCD_B	<=	0;
		mDATAd_0<=	0;
		mDATAd_1<=	0;
		mDVAL	<=	0;
	end
	else
	begin
		mDATAd_0	<=	mDATA_0;
		mDATAd_1	<=	mDATA_1;
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
		if({iY_Cont[0],iX_Cont[0]}==2'b10)
		begin
			mCCD_R	<=	mDATA_0;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATAd_1;
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)
		begin
			mCCD_R	<=	mDATAd_0;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATA_1;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)
		begin
			mCCD_R	<=	mDATA_1;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATAd_0;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b01)
		begin
			mCCD_R	<=	mDATAd_1;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATA_0;
		end
	end
end

endmodule
