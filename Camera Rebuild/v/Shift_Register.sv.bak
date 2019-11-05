module Shift_Register(
	input iCLK,
	input iRST,
	input iDVAL,
	input [9:0] iX,
	input [9:0] iY,
	input [11:0] grayVal,
	input iFilter,
	output oDVAL,
	output [11:0] oDATA
	);

reg [11:0] shift_reg[1281:0];

wire unsigned [18:0] PXL_cnt;
reg signed [19:0] TARG_cnt;

integer i;

always_ff @(posedge iDVAL, negedge iRST)
  if(!iRST)
    shift_reg <= '{default:0};
  else begin//if(iDVAL) begin
    for (i=1281; i > 0; i--) begin
      shift_reg[i] <= shift_reg[i-1];
    end
    shift_reg[0] <= grayVal;
  end

/* always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    PXL_cnt <= 0;
  else if(iDVAL && PXL_cnt < 19'd307200)
    PXL_cnt <= PXL_cnt + 1;
  else if(PXL_cnt == 19'd307200)
    PXL_cnt <= 0; */
	
assign PXL_cnt = (iY * 640) + iX;


always_ff @(posedge iDVAL, negedge iRST)
  if(!iRST)
    TARG_cnt <= -20'd641;
  else begin //if(iDVAL) begin
    TARG_cnt <= TARG_cnt + 1;
	if (TARG_cnt >= 20'd307199)
		TARG_cnt <= PXL_cnt - 20'd641;
  end

reg signed [10:0] X, Y;
/* always_ff @(posedge iCLK, negedge iRST)
  if(!iRST) begin
	X <= -1;
	Y <= -1;
  end
  else if(X == 10'd639 && Y == 10'd479) begin
    X <= iX - 1;
	Y <= iY - 1;
  end
  else if(iDVAL || (X > 10'd638 && Y == 10'd478) || Y == 10'd479) begin
    if (X == 10'd639) begin
		X <= 0;
		Y <= Y + 1;
	end
	else
		X <= X + 1;
  end */

/* assign oDVAL = (X < 0 || Y < 0) ? 0 :
  ((X > 10'd638 && Y == 10'd478) || Y == 10'd479) ? 1 :
  iDVAL; */
assign oDVAL = TARG_cnt < 0 ? 0 : iDVAL;


/* wire signed [10:0] X, Y; */
assign X = TARG_cnt % 640;
assign Y = TARG_cnt / 640;

wire edge_N, edge_S, edge_E, edge_W;
assign edge_N = Y == 0;
assign edge_S = Y == 479;
assign edge_W = X == 0;
assign edge_E = X == 639;

wire signed [11:0] kernel [2:0][2:0];
assign kernel[2][2] = edge_N && edge_W ? shift_reg[640] : 
					  edge_N ? shift_reg[641] :
					  edge_W ? shift_reg[1280] :
					  shift_reg[1281];
assign kernel[2][1] = edge_N ? shift_reg[640] : shift_reg[1280];
assign kernel[2][0] = edge_N & edge_E ? shift_reg[640] :
					  edge_N ? shift_reg[639] :
					  edge_E ? shift_reg[1280] :
					  shift_reg[1279];
assign kernel[1][2] = edge_W ? shift_reg[640] : shift_reg[641];
assign kernel[1][1] = shift_reg[640];
assign kernel[1][0] = edge_E ? shift_reg[640] : shift_reg[639];
assign kernel[0][2] = edge_S && edge_W ? shift_reg[640] :
					  edge_S ? shift_reg[641] :
					  edge_W ? shift_reg[0] :
					  shift_reg[1];
assign kernel[0][1] = edge_S ? shift_reg[640] : shift_reg[0];
assign kernel[0][0] = edge_S && edge_E ? shift_reg[640] :
					  edge_S ? shift_reg[639] :
					  edge_E ? shift_reg[0] :
					  grayVal;

/*wire signed [2:0] sobel_v [2:0][2:0], sobel_h[2:0][2:0];
assign sobel_v[0][2] = -1;
assign sobel_v[0][1] = 0;
assign sobel_v[0][0] = 1;
assign sobel_v[1][2] = -2;
assign sobel_v[1][1] = 0;
assign sobel_v[1][0] = 2;
assign sobel_v[2][2] = -1;
assign sobel_v[2][1] = 0;
assign sobel_v[2][0] = 1;

assign sobel_h[0][2] = 1;
assign sobel_h[0][1] = 2;
assign sobel_h[0][0] = 1;
assign sobel_h[1][2] = 0;
assign sobel_h[1][1] = 0;
assign sobel_h[1][0] = 0;
assign sobel_h[2][2] = -1;
assign sobel_h[2][1] = -2;
assign sobel_h[2][0] = -1;


wire [12:0] data, data_v, data_h;
assign data_v = 
  kernel[0][0] * sobel_v[0][0] +
  kernel[0][2] * sobel_v[0][2] +
  kernel[1][0] * sobel_v[1][0] +
  kernel[1][2] * sobel_v[1][2] +
  kernel[2][0] * sobel_v[2][0] +
  kernel[2][2] * sobel_v[2][2] ;

assign data_h =
  kernel[0][0] * sobel_h[0][0] +
  kernel[0][1] * sobel_h[0][1] +
  kernel[0][2] * sobel_h[0][2] +
  kernel[2][0] * sobel_h[2][0] +
  kernel[2][1] * sobel_h[2][1] +
  kernel[2][2] * sobel_h[2][2] ;

assign data = iFilter? data_v: data_h;
*/


wire signed [11:0] data;
assign data = iFilter ? 
  kernel[0][0] -
  kernel[0][2] +
  (kernel[1][0] << 1) -
  (kernel[1][2] << 1) +
  kernel[2][0] -
  kernel[2][2] :
  kernel[0][0] +
  (kernel[0][1] << 1) +
  kernel[0][2] -
  kernel[2][0] -
  (kernel[2][1] << 1) -
  kernel[2][2];


assign oDATA = data[11] ? -data : data; 

endmodule
