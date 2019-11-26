module CropDownMean(
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
	output [23:0] oSC
	);

localparam X_init = 27, Y_init = 17, X_max = 614, Y_max = 464, Sx = 21, Sy = 16;

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

reg [4:0] idx;
always @(posedge iCLK, negedge iRST)
  if(!iRST)
    idx <= 0;
  else if(buf_rst)
    idx <= 0;
  else if(X == X_init)
    idx <= 0;
  else if((X - X_init) % Sx == 0)
    idx <= idx + 1;

wire in_range;
assign in_range = (X >= X_init) && (X <= X_max) && (iY >= Y_init) && (iY <= Y_max);

logic [27:0][20:0] shift_reg;
logic [27:0][11:0] temp;
integer x;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST) begin
    shift_reg <= '{default:0};
  end
  else if(iY - Y_init % Sy == 0 && X == 1) begin
    shift_reg <= '{default:0};
  end
  else if(iDVAL && in_range) begin
    shift_reg[idx] <= shift_reg[idx] + grayVal;
  end

wire sample_pxl;
assign sample_pxl = iDVAL && (X == X_max) && ((iY - Y_init) % Sy == Sy - 1);

always_ff @(posedge iCLK, negedge iRST)
  if(!iRST) begin
    temp <= '{default:0};
  end
  else if(buf_rst)
    temp <= '{default:0};
  else if(sample_pxl) begin
    for(x = 0; x < 28; x = x + 1) begin
      temp[x] <= (shift_reg[x][20:9]);
    end
  end

wire RDY;
assign RDY = sample_pxl;

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


//// Output to VGA for debugging ////
reg [783:0][11:0] cropdown;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    cropdown <= '{default:0};
  else if(buf_rst)
    cropdown <= '{default:0};
  else if(RDY)
    for(x = 0; x < 28; x = x + 1) begin
      cropdown <= {temp[x],cropdown[783:1]};
    end
    //cropdown <= {temp, cropdown[783:28]};

reg [9:0] sample_cnt;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    sample_cnt <= '{default:0};
  else if(buf_rst)
    sample_cnt <= '{default:0};
  else if(RDY)
    sample_cnt <= sample_cnt + 28;

assign oSC = {cropdown[28],cropdown[27]};

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
assign oDATA = (oX < 28 && oY < 28) ? cropdown[(oX % 28)+(28*(oY%28))] : 0;//cropdown[(oX % 28)+(28*(oY%28))];//(oX < 28 && oY < 28) ? shift_reg[(oX + 28*oY)] : 0;


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
