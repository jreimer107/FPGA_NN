module Mult(input clk,
    input reset,
    input [7:0] input_neuron,
    input Weight_bit,
    output [7:0] out);

localparam Integer_width = 4;
localparam Fraction_width = 3;

reg [15:0] partial_out;
reg [3:0] counter;
reg [7:0] output_reg;
reg [3:0] integer_rounding;

always @(posedge clk) begin
	if (!reset)
		begin
			partial_out <=0;
			counter <=0;
                        output_reg <=0;
		end
	else
	begin
		if (counter == 0)
		begin
			partial_out =(input_neuron[6:0] * Weight_bit);
			counter <= counter +1'b1;
		end
		else if (counter == 7)
		begin
			partial_out[15] <= input_neuron[7] ^ Weight_bit;
			if ( partial_out[10])
				integer_rounding = partial_out[14:11] + 1'b1;
			else 	
				integer_rounding = partial_out[14:11] ;

			output_reg <= {partial_out[15], integer_rounding[3:0], partial_out [5:3]};
			partial_out <=0;
			counter <=0;
		end
		else
		begin
			partial_out = ((input_neuron[6:0] * Weight_bit)) + (partial_out << 1);
			counter <= counter +1'b1;
		end
	end
end


assign out = output_reg;

endmodule
