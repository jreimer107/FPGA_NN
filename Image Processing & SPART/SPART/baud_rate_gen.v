/*
Baud Rate Generator 
Holds a 16-bit value and repeatedly outputs an enable signal after that number of clock cycles
*/
module baud_rate_gen(
	input [7:0] DB_value,
	input clk,
	input rst,
	input [1:0] ioaddr,
	output enable,
	output [9:0] DB
	);

reg [15:0] divisor_buf;
reg [15:0] down_cnt;

//wire [7:0] DB_low, DB_high; 
assign DB = divisor_buf[9:0];
//assign DB_high = divisor_buf[15:8];

always @(posedge clk, posedge rst)
  if(rst)
	divisor_buf = 16'd325;
  else if(ioaddr == 2'b10)
	divisor_buf[7:0] = DB_value;
  else if(ioaddr == 2'b11)
	divisor_buf[15:8] = DB_value;

always @(posedge clk, posedge rst) begin
  if(rst)
	down_cnt = 16'd325;
  else if(enable)
	down_cnt = divisor_buf;
  else if(~ioaddr[1])
	down_cnt = down_cnt - 1;
  else
	down_cnt = divisor_buf;
end

// Enable signal is high when down_cnt is 0
assign enable = ~|down_cnt;

endmodule
