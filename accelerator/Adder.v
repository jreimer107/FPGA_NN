module Fixed_adder ( 
	input   [15:0] in1,
	input  [15:0] in2,
	input carry_in,
	output  [15:0] sum,
	output carry_out);

wire [15:0] sum1;


assign {carry_out, sum1} = in1 + in2 + carry_in;


//// check overflow 
assign overflow_pos = (~in1[15] & ~in2[15] & sum1[15]) ? 1 : 0;
assign overflow_high = ( in1[15] & in2[15] & ~sum1[15]) ? 1: 0;

assign sum = overflow_pos ? 16'b0111111111111111:
	     overflow_high ? 16'b1000000000000000:
	     sum1;
endmodule
