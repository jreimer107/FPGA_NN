module Normalize(
	input [11:0] pixelValue,
	input Rdy,
	input rst,
	input clk,
	output reg got_pxl,
	output ImgDone,
	output reg [783:0][15:0] normBuff);
	
reg [9:0] counter_next, counter_current;

logic[9:0] counter;

always @(posedge clk, negedge rst) begin
  if(!rst) begin
    got_pxl <= 0;
    normBuff <= '{default:0};
  end
  else if(Rdy) begin
    normBuff[counter] <= {8'b0, pixelValue[11:4]};
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
