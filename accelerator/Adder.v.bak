module Fixed_adder ( 
	input   [7:0] in1,
	input  [7:0] in2,
	input carry_in,
	output  [7:0] sum,
	output carry_out);

wire [7:0] sum1;


assign {carry_out, sum1} = in1 + in2 + carry_in;


//// check overflow 
assign overflow_pos = (~in1[7] & ~in2[7] & sum1[7]) ? 1 : 0;
assign overflow_high = ( in1[7] & in2[7] & ~sum1[7]) ? 1: 0;

assign sum = overflow_pos ? 8'b01111111:
	     overflow_high ? 8'b10000000:
	     sum1;
endmodule
