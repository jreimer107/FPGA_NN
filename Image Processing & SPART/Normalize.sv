module Normalize(
	input [11:0] pixelValue,
	input Rdy,
	input rst,
	input clk,
	output ImgDone,
	output reg [783:0][11:0] normBuff);
	
reg [9:0] counter_next, counter_current;

logic[9:0] counter;
//assign counter = 10'd0;	
localparam [6:0] mean = 33, sd = 64; // mean = 33

logic got_pxl;

always @(posedge clk, negedge rst) begin
  if(!rst) begin
    got_pxl <= 0;
    normBuff <= '{default:0};
  end
  else if(Rdy) begin
    normBuff[counter] <= (pixelValue - mean) >> 6;
    got_pxl <= 1;
  end
  else
    got_pxl <= 0;
end

always @(posedge clk, negedge rst)
  if(!rst)
    counter <= 0;
  else if(got_pxl)
    if(counter >= 783)
      counter <= 0;
    else
      counter <= counter + 1;

assign ImgDone = counter == 783;


endmodule
