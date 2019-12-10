module ALU (
	input [15:0]a,
	input [15:0]b,
	input [4:0]ctrl,
	output [15:0]out,
	output reg ovfl
);

wire ovfl_temp;
wire sub;
reg [15:0]out_temp;

wire [15:0]out_addsub;

assign out = out_temp;
assign sub = (ctrl == 5'h1);

always_comb begin
	ovfl = 0;
	case (ctrl)
		5'h0,
		5'h1: begin
			out_temp = out_addsub;
			ovfl = ovfl_temp;
		end
		5'h2: out_temp = a & b;
		5'h3: out_temp = a | b;
		5'h4: out_temp = a ^ b;
		5'h5: out_temp = a << b[3:0];
		5'h6: out_temp = a >>> b[3:0];
		5'h8: out_temp = {a[15:8], b[7:0]}; // IMML
		5'h9: out_temp = {b[7:0], a[7:0]};  // IMMH
		default: out_temp = 16'b0;
	endcase
end


ADDSUB U_ADDSUB(
	.a(a),
	.b(sub ? -b : b),
	.sum(out_addsub),
	.ovfl(ovfl_temp)
);

endmodule