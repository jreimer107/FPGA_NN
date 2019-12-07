module accumulation_register(
	input clk,
	input reset,
	input [15:0] partial_sum,
	input add_done,
	input neuron_done,
	output [15:0] new_sum);

reg [15:0] new_sum_reg;

always @(posedge clk)
begin
if (!reset)
	new_sum_reg <=0;
else if(add_done)
	new_sum_reg = partial_sum + new_sum_reg;
else if(neuron_done)
	new_sum_reg <=0;
end

assign new_sum = new_sum_reg;
endmodule
