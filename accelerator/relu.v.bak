module relu(
	input clk,
	input rst,
	input neuron_done,
	input [15:0]neuron,
	output[15:0]out,
	output cpu_neuron_done);

reg [15:0]out_reg;
reg cpu_sig;

always@(posedge clk)
	if(!rst) begin
		out_reg <=0;
		cpu_sig <=0;
	end
	else if(neuron_done)
	begin
		out_reg <= neuron[15]? 0 : neuron;
		cpu_sig <= 1'b1;
	end
	else
		cpu_sig <= 1'b0;		

assign out = out_reg;
assign cpu_neuron_done = cpu_sig;

endmodule