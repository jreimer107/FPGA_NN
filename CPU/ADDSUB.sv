module ADDSUB (
	input [15:0]a,
	input [15:0]b,
	output [15:0]sum,
	output ovfl
);

wire pos_ovfl, neg_ovfl;
wire [15:0]sum_temp = a + b;

//Saturation
assign pos_ovfl = (sum_temp[15] & ~a[15] & ~b[15]);
assign neg_ovfl = (~sum_temp[15] & a[15] & b[15]);
assign ovfl = pos_ovfl | neg_ovfl;
assign sum = pos_ovfl ? 16'h7FFF :
	   neg_ovfl ? 16'h8000 :
	   sum_temp;

endmodule