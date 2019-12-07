module Mult(input clk,
    input reset,
    input [15:0] input_neuron,
    input Weight_bit,
    input enable,
    output [15:0] out);

localparam Integer_width = 5;
localparam Fraction_width = 10;

reg [31:0] partial_out;
reg [3:0] counter;
reg [3:0] count_zeros;
reg [15:0] output_reg;
reg [4:0] integer_rounding;
reg enable_delay;

always @(posedge clk) begin
	if (!reset)
		begin
			partial_out <=0;
			counter <=0;
                        output_reg <=0;
			enable_delay <=0;
		end
	else if (enable)
		enable_delay <=1; 
	
	if(enable_delay)
	begin
		if (counter == 0)
		begin
			partial_out = (input_neuron[14:0] * Weight_bit);
			counter <= counter +1'b1;
		end
		else if (counter == 15)
		begin
			partial_out[31] <= input_neuron[15] ^ Weight_bit;
			//if (partial_out[30:20] >= 11'd32)
			//	integer_rounding = partial_out[27:23];
			//else 
			//begin
			if(partial_out[26]) begin
				integer_rounding = partial_out[25:21];
			end
			else
			begin
				integer_rounding = partial_out[24:20];
			end
			output_reg <= {partial_out[31], integer_rounding[4:0], partial_out [19:10]};
			partial_out <=0;
			counter <=0;
		end
		else
		begin
			partial_out = ((input_neuron[14:0] * Weight_bit)) + (partial_out << 1);
			counter <= counter +1'b1;
		end
	end
end


assign out = output_reg;

endmodule
