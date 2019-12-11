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

wire ccd_enable;
wire ccd_done;
wire ccd_dmem_wren;
wire [6:0] ccd_dmem_wraddr;
wire [255:0] ccd_dmem_wrdata;
wire [1:0] state;

wire bram_ren;
wire bram_wren;
wire [10:0] bram_addr;
wire [15:0] bram_data_in;
wire [15:0] bram_data_out;
wire acc_done;
wire acc_en;
wire bus_wr;
wire [15:0] bus_data;
wire pc_advance;
wire [3:0] reg_index = SW[3:0];
wire halt;
wire [23:0] instr_out;
wire [15:0] pc_out;
wire [15:0] reg_out;
wire ccd_done_reg;

//=======================================================
//  Structural coding
//=======================================================

assign	LEDR	=	{2'b0, ccd_enable, ccd_done, state[1:0], pc_out[3:0]};

wire clk, rst_n;
assign clk = CLOCK_50;
assign rst_n = KEY[0];

reg [23:0] seg7_output;
reg [6:0] ccd_dmem_wren_cnt;
reg		 ccd_dmem_wren_buf;
reg [6:0] ccd_dmem_wraddr_buf;

always @(posedge CLOCK_50) begin
	if (SW[9])
		seg7_output <= {18'h0, ccd_dmem_wren_cnt};
   else if(SW[4])
      seg7_output <= {18'h0, ccd_dmem_wraddr_buf};
	else begin
	   if (SW[8])
		   seg7_output <= instr_out;
	   else
		   seg7_output <= {8'h0, reg_out};
   end
end


always @(posedge CLOCK_50) begin
   if(!KEY[0]) begin
      ccd_dmem_wren_cnt <= 7'h0;
      ccd_dmem_wren_buf <= 1'b0;
      ccd_dmem_wraddr_buf <= 7'h0;
   end
   else begin
      ccd_dmem_wren_cnt <= ccd_dmem_wren_buf ? ccd_dmem_wren_cnt + 1 : ccd_dmem_wren_cnt;
      ccd_dmem_wraddr_buf <= ccd_dmem_wren_buf ? ccd_dmem_wraddr : ccd_dmem_wraddr_buf;
      ccd_dmem_wren_buf <= ccd_dmem_wren;
   end
end

IPSM u1 (

	//////////// CLOCK //////////
	.CLOCK2_50(CLOCK2_50),
	.CLOCK_50(CLOCK_50),
   .rst_n(rst_n),

   .start_key(!KEY[3]),
   .exposure_key(!KEY[2]),
	.exposure_sw(SW[7]),
   .zoom_sw(SW[6]),

    // CPU interface
	.enable(ccd_enable),
	.ccd_done(ccd_done),

	// DMEM interface
	.dmem_wren(ccd_dmem_wren),
	.dmem_wraddr(ccd_dmem_wraddr),
	.dmem_wrdata(ccd_dmem_wrdata),

	.state(state),
	.Frame_Cont(Frame_Cont),

	//////////// GPIO_1, GPIO_1 connect to D5M - 5M Pixel Camera //////////
   .D5M_D(D5M_D),
	.D5M_FVAL(D5M_FVAL),
	.D5M_LVAL(D5M_LVAL),
	.D5M_PIXLCLK(D5M_PIXLCLK),
	.D5M_RESET_N(D5M_RESET_N),
	.D5M_SCLK(D5M_SCLK),
	.D5M_SDATA(D5M_SDATA),
	.D5M_TRIGGER(D5M_TRIGGER)
);


cpu  u3(
	.clk(clk),                   // Clock
	.rst_n(rst_n),                 // Asynchronous reset active low

	// DMEM interface
	.dmem_data_from(bram_data_in),    // load data from data BRAM
	.dmem_ren(bram_ren),          // enable BRAM for read
	.dmem_wren(bram_wren),          // write enable to BRAM
	.dmem_addr(bram_addr), // read/write address to BRAM
	.dmem_data_to(bram_data_out),  // store data to BRAM

	// Accelerator interface
	.accel_done(acc_done),
	// output accel_start,
	.accel_en(acc_en),
	.bus_wr(bus_wr),
	// output [2:0] bus_accregaddr,
	.bus_data(bus_data),

	//IPU interface
	.ccd_done(ccd_done),
	.ccd_en(ccd_enable),

	// Testing/Demo signals
	.pc_advance(pc_advance),
	.reg_index(reg_index),
	.halt(halt),
	.instr_out(instr_out),
	.pc_out(pc_out),
	.reg_out(reg_out),
	.ccd_done_reg(ccd_done_reg)
);

ram u4 (
	.address_a(bram_addr),
	.address_b(ccd_dmem_wraddr),
	.clock(clk),
	.data_a(bram_data_out),
	.data_b(ccd_dmem_wrdata),
	.rden_a(bram_ren),
	.rden_b(1'b0),
	.wren_a(bram_wren),
	.wren_b(ccd_dmem_wren),
	.q_a(bram_data_in),
	.q_b());


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

endmodule
