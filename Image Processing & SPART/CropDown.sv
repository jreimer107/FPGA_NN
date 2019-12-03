module CropDown(
	input iCLK,
	input iRST,
	input iDVAL,
	input buf_rst,
	//input [9:0] iX,
	input [9:0] iY,
	input [11:0] grayVal,
	//input iFilter,
	output oDVAL,
	output [11:0] oDATA,
	output [23:0] oSC,
	//output reg [10:0] wr_addr,
	output done,
	output [783:0][15:0] img
	//output bram_wr_en
	);

localparam X_init = 27, Y_init = 17, X_max = 614, Y_max = 464, Sx = 21, Sy = 16;

logic [11:0] shift_reg;

always_ff @(posedge iCLK, negedge iRST)
  if(!iRST) begin
    shift_reg <= '{default:0};
  end
  else if(iDVAL) begin
    shift_reg <= grayVal;
  end

reg [9:0] X;

always @(posedge iCLK, negedge iRST)
  if(!iRST)
    X <= 0;
  else if(buf_rst)
    X <= 0;
  else if(iDVAL)
    if(X == 640)
      X <= 1;
    else
      X <= X + 1;

wire in_range;
assign in_range = (X >= X_init) && (X <= X_max) && (iY >= Y_init) && (iY <= Y_max);

wire sample_pxl;
assign sample_pxl = in_range && ((X - X_init) % Sx == 0) && ((iY - Y_init) % Sy == 0);

wire RDY;
assign RDY = sample_pxl && iDVAL;

reg [11:0] out;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST) begin
    out <= '{default:0};
  end
  else if(buf_rst)
    out <= '{default:0};
  else if(sample_pxl) begin
    out <= grayVal;
  end


//wire pxlVAL, done;

//logic [783:0][15:0] norm, norm_buf;

//wire [15:0] norm_pxl;

Normalize normal(
	.pixelValue(out),
	.Rdy(RDY),
	.rst(iRST),
	.clk(iCLK),
	.got_pxl(pxlVAL),
	.ImgDone(done),
	.normBuff(img));
/*
reg start_bram_wr;

always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    start_bram_wr <= 0;
  else if(wr_addr == 49)
    start_bram_wr <= 0;
  else if(done)
    start_bram_wr <= 1;

assign bram_wr_en = pxlVAL;//start_bram_wr;

always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    wr_addr <= 0;
  else if(pxlVAL)
    if(wr_addr == 783)
      wr_addr <= 0;
    else
      wr_addr <= wr_addr + 1;


always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    norm_buf <= 0;
  else if(done)
    norm_buf <= norm;
  else if(wr_addr > 0)
    norm_buf <= {256'b0, norm[783:16]};

assign bram_oDATA = norm_pxl;//start_bram_wr ? norm_buf[15:0] : 256'bz;
*/

/*
//	Normalization with VGA output
wire done;

logic [783:0][11:0] norm;

Normalize normal(
	.pixelValue(out),
	.Rdy(RDY),
	.rst(iRST),
	.clk(iCLK),
	.ImgDone(done),
	.normBuff(norm));

//// Output to VGA for debugging ////
reg [783:0][11:0] cropdown;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    cropdown <= '{default:0};
  else if(buf_rst)
    cropdown <= '{default:0};
  else if(done)
    cropdown <= norm;

reg [9:0] sample_cnt;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    sample_cnt <= '{default:0};
  else if(buf_rst)
    sample_cnt <= '{default:0};
  else if(done)
    sample_cnt <= 784;

assign oSC = {cropdown[783],cropdown[0]};

reg [6:0] clk_cnt;
always @(posedge iCLK, negedge iRST)
  if(!iRST)
    clk_cnt <= 0;
  else if(buf_rst)
    clk_cnt <= 0;
  else if(sample_cnt >= 784)
    clk_cnt <= clk_cnt + 1;

wire modDVAL;
reg [19:0] TARG_cnt;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    TARG_cnt <= 0;
  else if(buf_rst)
    TARG_cnt <= 0;
  else if(modDVAL) begin
    TARG_cnt <= TARG_cnt + 1;
  end

assign modDVAL = &clk_cnt && TARG_cnt <= 307200;

wire [9:0] oX, oY;
assign oX = TARG_cnt % 640;
assign oY = TARG_cnt / 640;

assign oDVAL = modDVAL;
assign oDATA = cropdown[(oX % 28)+(28*(oY%28))];//(oX < 28 && oY < 28) ? shift_reg[(oX + 28*oY)] : 0;
*/

//// Output to VGA for debugging ////
reg [783:0][11:0] cropdown;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    cropdown <= '{default:0};
  else if(buf_rst)
    cropdown <= '{default:0};
  else if(RDY)
    cropdown <= {shift_reg, cropdown[783:1]};

reg [9:0] sample_cnt;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    sample_cnt <= '{default:0};
  else if(buf_rst)
    sample_cnt <= '{default:0};
  else if(RDY)
    sample_cnt <= sample_cnt + 1;

assign oSC = {cropdown[783],cropdown[0]};

reg [6:0] clk_cnt;
always @(posedge iCLK, negedge iRST)
  if(!iRST)
    clk_cnt <= 0;
  else if(buf_rst)
    clk_cnt <= 0;
  else if(sample_cnt >= 784)
    clk_cnt <= clk_cnt + 1;

wire modDVAL;
reg [19:0] TARG_cnt;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    TARG_cnt <= 0;
  else if(buf_rst)
    TARG_cnt <= 0;
  else if(modDVAL) begin
    TARG_cnt <= TARG_cnt + 1;
  end

assign modDVAL = &clk_cnt && TARG_cnt <= 307200;

wire [9:0] oX, oY;
assign oX = TARG_cnt % 640;
assign oY = TARG_cnt / 640;

assign oDVAL = modDVAL;
assign oDATA = cropdown[(oX % 28)+(28*(oY%28))];//(oX < 28 && oY < 28) ? shift_reg[(oX + 28*oY)] : 0;


/*
reg sample_line;
always @(posedge iCLK, negedge iRST)
  if(!iRST)
    sample_line <= 0;
  else if(((iY - Y_init) % Sy == 0) && X == 1 && iY >= Y_init && iY <= Y_max)
    sample_line <= 1;
  else
    sample_line <= 0;

reg [9:0] row_pxl_cnt, row_cnt;

reg [4:0] Xsample_cnt;
always @(posedge iCLK, negedge iRST)
  if(!iRST)
    Xsample_cnt <= 0;
//  else if(Xsample_cnt >= 28)
//    if(Xsample_cnt == 28)
//      Xsample_cnt <= 29;
//    else if(X == 1)
//      Xsample_cnt <= 0;
  else if(Xsample_cnt >= 28)
    if(row_pxl_cnt == 639)
      Xsample_cnt <= 0;
    else
      Xsample_cnt <= 29;
  else if(iDVAL)
    if(in_range && ((X - X_init) % Sx == 0) && ((iY - Y_init) % Sy == 0))
      Xsample_cnt <= Xsample_cnt + 1;

always @(posedge iCLK, negedge iRST)
  if(!iRST)
    row_pxl_cnt <= 0;
  else if(row_pxl_cnt == 639)
    row_pxl_cnt <= 0;
  else if(sample_pxl || (Xsample_cnt > 28))
    row_pxl_cnt <= row_pxl_cnt + 1;

reg [4:0] Ysample_cnt;
always @(posedge iCLK, negedge iRST)
  if(!iRST)
    Ysample_cnt <= 0;
  else if(Ysample_cnt >= 28)
    if(Ysample_cnt == 28)
      Ysample_cnt <= 29;
    else if(iY == 0)
      Ysample_cnt <= 0;
  else if(sample_line)
    Ysample_cnt <= Ysample_cnt + 1;

always @(posedge iCLK, negedge iRST)
  if(!iRST)
    row_cnt <= 0;
  else if(row_cnt == 479)
    row_cnt <= 0;
  else if(row_pxl_cnt == 639)
    row_cnt <= row_cnt + 1;



assign oDVAL = (Xsample_cnt <= 28 && Ysample_cnt <= 28) ? sample_pxl && iDVAL : row_pxl_cnt < 640 && row_cnt < 480 && row_cnt > 0 ? modDVAL : 0;
assign oDATA = (Xsample_cnt <= 28 && Ysample_cnt <= 28) ? shift_reg : 0;
*/

endmodule
