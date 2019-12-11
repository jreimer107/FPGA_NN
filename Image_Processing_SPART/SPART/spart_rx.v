/*
Receiver
Receives an input bit and begins shifting the input into a buffer when a start
bit (0) is received. The first bit is shifted in after 8 enable signals, then 
subsequent bits are shifted in after 16 enable signals are received
*/
module spart_rx(
	input clk,
	input rst,
	input enable,
	input rxd,
	output reg [7:0] data,
	output [7:0] rx_capture,
	output rda
);

reg [8:0] rx_buf;
reg [3:0] bit_cnt;
reg [4:0] en_cnt;
reg start_detected;
reg old;

reg [4:0] old_en_cnt;
wire count;
wire sample;

// Single cycle signals used as enables to flops
assign count = en_cnt == 5'd16 & old_en_cnt == 5'd15;
assign zero = en_cnt == 5'd1 & old_en_cnt == 5'd16;
assign sample = en_cnt == 5'd8 & old_en_cnt == 5'd7;

always @(posedge clk, posedge rst)
  if(rst)
	old = 1;
  else if (enable)
	old = rxd;

// Falling edge detector for detecting start bit
always @(posedge clk, posedge rst)
  if(rst)
	start_detected = 0;
  else if(bit_cnt == 0 && ~rxd && old)
	start_detected = 1;
  else if(bit_cnt == 4'd0 && zero)
	start_detected = 0;

always @(posedge clk, posedge rst)
  if(rst)
	old_en_cnt = 5'h00;
  else
	old_en_cnt = en_cnt;

always @(posedge clk, posedge rst)
  if(rst)
	rx_buf = 9'b111111111;
  else if(start_detected && sample)
	rx_buf = {rxd, rx_buf[8:1]};

wire [4:0] in;

// Counter keeping track of the number of enable signals received
assign in = start_detected ? 
		~enable ? en_cnt :
		enable ? (en_cnt == 5'd16) ? 5'h01 : ( en_cnt + 1 ) : 5'h01 : 5'h00;
always @(posedge clk, posedge rst)
  if(rst)
	en_cnt = 5'h00;
  else
	en_cnt = in;

// Counts from zero to ten keeping track of how many bits have been received
always @(posedge clk, posedge rst)
  if(rst) begin
	bit_cnt = 4'd0;
  end
  else if(bit_cnt == 4'd10 && count) begin
	bit_cnt = 4'd0;
  end
  else if(rx_buf[8] == 0 && bit_cnt == 0 && count)
	bit_cnt = 4'd1;
  else if(count && bit_cnt > 0) begin
	bit_cnt = bit_cnt + 1;
  end

always @(posedge clk, posedge rst)
  if(rst)
	data = 8'hFF;
  else if(bit_cnt == 4'd10 && sample)
	data = rx_buf[7:0];

// Test signal
assign rx_capture = data;

assign rda = bit_cnt == 4'd10 && count ? 1 : 0;

endmodule
