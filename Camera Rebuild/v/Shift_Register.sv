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

// Single shift register to hold 2 rows of pixels
logic [1281:0][11:0]shift_reg;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    shift_reg <= '{default:0};
  else if(iDVAL)
	shift_reg <= {shift_reg[1280:0], grayVal};
	
// Position of target of convolution is 1 row, 1 pixel before input (-641)
reg signed [19:0] TARG_cnt;
always_ff @(posedge iCLK, negedge iRST)
  if(!iRST)
    TARG_cnt <= -20'd641;
  else if(iDVAL) begin
    TARG_cnt <= TARG_cnt + 1;
	if (TARG_cnt == 20'd307199)
		TARG_cnt <= 640*(iY - 1) + iX - 1;
  end

// Suppress dval if target pixel doesn't exist, negative position
assign oDVAL = TARG_cnt < 0 ? 0 : iDVAL;

// Find X and Y positions of target
wire signed [10:0] X, Y;
assign X = TARG_cnt % 640;
assign Y = TARG_cnt / 640;

// Detect if Target is an edge pixel and which edge it is on
wire edge_N, edge_S, edge_E, edge_W;
assign edge_N = Y == 0;
assign edge_S = Y == 479;
assign edge_W = X == 0;
assign edge_E = X == 639;

// Kernel is tied to positions in shift register
// If kernel pixels are off the edge, replicate the closest existant pixel
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

// Run convolution on data. Filter used based on switch position
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

//Output absolute value of convolution result
assign oDATA = data[11] ? -data : data;
endmodule
