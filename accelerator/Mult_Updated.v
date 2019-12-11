module Mult(input clk,
    input reset,
    input [15:0] input_neuron,
    input Weight_bit,
    input enable,
    output [15:0] out);

localparam Integer_width = 5;
localparam Fraction_width = 10;

reg [31:0] partial_out, partial_out_dummy;
reg [4:0] counter, c;
reg [3:0] count_zeros;
reg [15:0] output_reg;
reg [4:0] integer_rounding;
reg enable_delay , sign;
reg [9:0] fraction_rounding;


always @ (posedge clk, negedge reset)
begin
if (!reset)
begin
			partial_out =0;
			counter = 0;
        	output_reg = 0;
			enable_delay <=0;
			sign = 0;
end

else if (enable)
begin
	if (counter ==0)
		begin
			partial_out_dummy = 0;
			partial_out = (input_neuron[14:0] * Weight_bit);
			counter = counter +1'b1;
			sign = 0;
			//output_reg[15] = 1'b0;
		end
			

	else if (counter < 15) begin
		//partial_out_dummy = 0;
		//c = counter -1;
		partial_out = ((input_neuron[14:0] * Weight_bit) << counter) + partial_out;
		counter = counter +1;
	end
	else 
	begin
	sign = input_neuron[15] ^ Weight_bit;
	partial_out_dummy= partial_out; //<<1;
	
	if(partial_out_dummy[26]) 
	begin
				integer_rounding =  5'b11111; //partial_out_dummy [25:21];
	end
	else if (partial_out_dummy[25])
	begin
				integer_rounding = 5'b11111; //partial_out_dummy[24:20];
	end
	else
				integer_rounding = partial_out_dummy[24:20];
				
				
	fraction_rounding = partial_out_dummy[19:10];
			
	output_reg = {sign, integer_rounding[4:0], fraction_rounding};
	partial_out =0;
	counter =0;
	end
end			


end
assign out = output_reg;
endmodule



/*always @(posedge clk) begin
	if (!reset)
		begin
			partial_out =0;
			counter =0;
         output_reg =0;
			enable_delay <=0;
			sign = 0;
		end
	//else if (enable)
	//	enable_delay <=1;
	//else if(!enable)
	//	enable_delay <=0;
	
	if(enable)
	begin
		if (counter == 0)
		begin
			partial_out_dummy = 0;
			partial_out = (input_neuron[14:0] * Weight_bit);
			counter = counter +1'b1;
		end
		else if (counter == 15)
		begin
			sign = input_neuron[15] ^ Weight_bit;
			
			begin
			partial_out_dummy = (partial_out << 1);
			
			if(partial_out_dummy[26]) begin
				integer_rounding =  5'b11111; //partial_out_dummy [25:21];
			end
			else if (partial_out_dummy[25])
			begin
				integer_rounding = 5'b11111; //partial_out_dummy[24:20];
			end
			else
				integer_rounding = partial_out_dummy[24:20];
				
				
			fraction_rounding = partial_out_dummy[19:10];
			
			output_reg = {sign, integer_rounding[4:0], fraction_rounding};
		   partial_out =0;
			counter =0;
			end
		end
		else		
		begin
			partial_out = ((input_neuron[14:0] * Weight_bit)<< (counter)) + (partial_out);
			counter = counter +1'b1;
		end
	end
end


assign out = output_reg; // {partial_out[31], integer_rounding[4:0], partial_out [19:10]};

endmodule
*/