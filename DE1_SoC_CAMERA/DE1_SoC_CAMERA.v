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

      ///////// ADC /////////
      inout              ADC_CS_N,
      output             ADC_DIN,
      input              ADC_DOUT,
      output             ADC_SCLK,
		
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

reg		    [11:0]			rCCD_DATA;
reg								rCCD_LVAL;
reg								rCCD_FVAL;
wire	       [11:0]			sCCD_R;
wire	       [11:0]			sCCD_G;
wire	       [11:0]			sCCD_B;
wire								sCCD_DVAL;

wire								sdram_ctrl_clk;

//=======================================================
//  Structural coding
//=======================================================

wire clk, rst_n;
assign clk = CLOCK_50;
assign rst_n = KEY[0];


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


assign	LEDR = {
    ccd_done,
    ccd_dmem_wren,
	ccd_en,
	state[1:0],
	halt,
    pc_out[3:0]
};

//Frame count display
SEG7_LUT_6 			u1	(	
							.oSEG0(HEX0),.oSEG1(HEX1),
							.oSEG2(HEX2),.oSEG3(HEX3),
							.oSEG4(HEX4),.oSEG5(HEX5),
							.iDIG(seg7_output)
						   );
												
sdram_pll 			u2	(
							.refclk(CLOCK_50),
							.rst(1'b0),
							.outclk_0(sdram_ctrl_clk),
							.outclk_1(DRAM_CLK),
							.outclk_2(D5M_XCLKIN),    //25M
					        .outclk_3(VGA_CLK)       //25M

						   );

// CCD
wire ccd_en;
wire ccd_done;
wire ccd_dmem_wren;
wire [6:0] ccd_dmem_addr;
wire [255:0] ccd_dmem_data;
wire [9:0] pxl_cnt;
wire ccd_start_cap;
wire captured;
wire start_key_press;
wire [1:0] state;

IPSM u3(
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
	// .cpu_done(cpu_done),
	//.ccd_start(ccd_start),
	.ccd_done(ccd_done),

	// DMEM interface
	.dmem_wren(ccd_dmem_wren),
	.dmem_wraddr(ccd_dmem_addr),
	.dmem_wrdata(ccd_dmem_data),
	.state(state),

	//GPIO1
	.D5M_D(D5M_D),
	.D5M_FVAL(D5M_FVAL),
	.D5M_LVAL(D5M_LVAL),
	.D5M_PIXLCLK(D5M_PIXLCLK),
	.D5M_RESET_N(D5M_RESET_N),
	.D5M_SCLK(D5M_SCLK),
	.D5M_SDATA(D5M_SDATA),
	.D5M_TRIGGER(D5M_TRIGGER)
);

//CPU dmem wires
wire [15:0] cpu_dmem_data, dmem_cpu_data;
wire [15:0] cpu_dmem_addr;
wire cpu_dmem_ren, cpu_dmem_wren;



cpu u4(
    .clk(clk),
    .rst_n(rst_n),

	//DMEM interface
    .dmem_ren(cpu_dmem_ren), 
    .dmem_wren(cpu_dmem_wren),
	 .dmem_addr(cpu_dmem_addr),  
    .dmem_data_to(cpu_dmem_data),
    .dmem_data_from(dmem_cpu_data),

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

ram u5(
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

endmodule
