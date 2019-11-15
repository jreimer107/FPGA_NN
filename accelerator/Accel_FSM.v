
module Accelerator_FSM(
	input clk,
	input rst,
	input [15:0] BaseAddr_W,
	input [15:0] BaseAddr_in,
	input [15:0] total_output_neurons,
	input [15:0] total_input_neurons,
	input DVAL,
	input accelerator_start, 
	input Enable,
	output [15:0] Waddress_current,
	output [15:0] Inaddress_current,
	output neuron_done
    );

 
	reg neuron_done_reg ;
	reg [5:0] Number_of_MAC_done;
	reg [9:0] Number_of_neurons_done;
	reg [15:0] InAddress;
	reg [15:0] WeightAddress;
	reg [2:0] state;
	reg [4:0] num_of_mults;
	reg[4:0] num_of_addition;
	parameter IDLE = 3'b000;
	parameter WAIT = 3'b001;
	parameter SetAddress = 3'b010;
	parameter Multiplication = 3'b011;
	parameter Addition = 3'b100;
	parameter UpdateCounters = 3'b101;
	
	parameter size_of_PE = 5'h10; /// we have 16 parallel  multipliers


always @ (posedge clk)

begin
if (rst)
	begin
	state <= IDLE;
	Number_of_MAC_done <= 0;
	Number_of_neurons_done <= 0;
	num_of_addition <=0;
	num_of_mults <= 0;
	end


case (state)
IDLE:
begin
if (Enable)
begin
	state <= WAIT ;
	neuron_done_reg <=0;
end
else 
begin
	state <= IDLE;
	neuron_done_reg <= 0;
end
end
 
WAIT:
begin
if (accelerator_start)
begin
	state <= SetAddress ;
end
else 
begin
	state <= WAIT;
end



end

//////////////////
SetAddress:
begin
    InAddress <= BaseAddr_in;
    WeightAddress <= BaseAddr_W;
    state <= Multiplication;
    neuron_done_reg <= 0;
end

//////////////
Multiplication:
begin
	if (DVAL)
	begin
		WeightAddress <= WeightAddress +1;
		num_of_mults <= num_of_mults +1;
	end
	if (num_of_mults == 15)
	begin
		state <= Addition;
		num_of_mults <=0;
                neuron_done_reg <= 0;
		if (Number_of_neurons_done == (total_output_neurons -2))
			InAddress <= BaseAddr_in;
		else
			InAddress <= InAddress + 16;

	end
	else 
	begin
		state <= Multiplication;
		neuron_done_reg <= 0;

	end
end


Addition:
begin
	if (DVAL)
	begin
		WeightAddress <= WeightAddress +1;
		num_of_mults <= num_of_mults +1;
	end
	num_of_addition <= num_of_addition +1;
	if (num_of_addition ==4)
	begin
		state <= UpdateCounters;
		neuron_done_reg <= 0;
		num_of_addition <= 0;
	end
	else
	begin
		state <= Addition;
		neuron_done_reg <= 0;
	end
end


UpdateCounters:
begin
	Number_of_MAC_done <= Number_of_MAC_done +1;
	if (Number_of_MAC_done == (total_input_neurons/size_of_PE)-1)
	begin
		neuron_done_reg <=1;
		Number_of_MAC_done <=0;
		Number_of_neurons_done <= Number_of_neurons_done +1;
		if (Number_of_neurons_done == total_output_neurons -1)
			Number_of_neurons_done<=0;
	end	
	if (Enable)
		state <= Multiplication;
	else
		state <= IDLE;
end


endcase
end

assign neuron_done =  neuron_done_reg;
assign Waddress_current = WeightAddress;
assign Inaddress_current= InAddress;


endmodule