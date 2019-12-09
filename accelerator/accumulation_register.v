module accumulation_register(
	input clk,
	input reset,
	input [15:0] partial_sum,
	input add_done,
	input neuron_done,
	output [15:0] new_sum);

reg [15:0] new_sum_reg, old_sum;
reg add_done_delay , carry_out;

assign sign1 = partial_sum[15];

always @(posedge clk)
begin
if (!reset)
	begin
	new_sum_reg =0;
	//old_sum <= 0;
	//add_done_delay <=0;
	end
else if(add_done)
	{carry_out, new_sum_reg} = partial_sum + old_sum;
	
if (~sign1 & ~old_sum[15] & new_sum_reg[15])
	new_sum_reg = 16'b0111111111111111;
else if (sign1 & old_sum[15] &  carry_out )
	new_sum_reg = 16'b1000000000000000;
else
	new_sum_reg = new_sum_reg;
end

always @(*)
	old_sum <= new_sum_reg;

assign new_sum = new_sum_reg;

endmodule
