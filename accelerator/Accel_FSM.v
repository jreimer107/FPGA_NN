module Accelerator_FSM(
    input clk,
    input rst,
    //input [1:0] status_reg,
    input [16:0] BaseAddr_W1,
    input [16:0] BaseAddr_W2,
    input [16:0] BaseAddr_in1,
    input [16:0] BaseAddr_in2,	
	input Layer_count,
	input accelerator_start, 
	input WB_full,
	input InB_full,
	input PE_ready,
	input PE_done,
	output [15:0] Waddress_current,
	output [15:0] Inaddress_current,
	output neuron_done
    );

 
	reg neuron_done_reg ;
	reg [1:0] Number_of_MAC_done;
	reg [7:0] Number_of_neurons_done;
	reg [15:0] InAddress;
	reg [15:0] WeightAddress;
	reg [2:0] state;
        reg [2:0] Total_Macs;
	parameter IDLE = 3'b000;
	parameter SetAddress = 3'b001;
	parameter ReadData = 3'b010;
	parameter PE_busy = 3'b011;
	parameter PE_compute = 3'b100;
	parameter UpdateCounters = 3'b101;
	
	parameter MAC_layer1 = 3'b001; /// we have 10 input neurons
	parameter MAC_layer2 = 3'b100; // we have 784 input neurons --> [784/256]= 3.06

always @ (posedge clk)

begin
if (rst)
	begin
	state <= IDLE;
	Number_of_MAC_done <= 0;
	Number_of_neurons_done <= 0;
	end


case (state)
IDLE:
begin
if (accelerator_start ==1)
begin
	state <= SetAddress ;
end
else 
begin
	state <= IDLE;
end
end

SetAddress:
begin
    if (Layer_count == 0)
     begin
	InAddress <= BaseAddr_in1 + (Number_of_MAC_done * 256);
	WeightAddress <= BaseAddr_W1;  ////How to update weight address buffer??
	state <= ReadData;
	Total_Macs <= MAC_layer1;
     end
     else
     begin
	InAddress = BaseAddr_in2 + (Number_of_MAC_done * 256);
	WeightAddress = BaseAddr_W2;  ////How to update weight address buffer??
	state <= ReadData;
	Total_Macs = MAC_layer2;
     end
  
end

ReadData:
begin
	if (WB_full ==0 | InB_full ==0)
	begin
		state <= ReadData;
	end
	else if (WB_full ==1 & InB_full ==1 & PE_ready ==0)
	begin
			state<=PE_busy;
	end
	else if (WB_full ==1 & InB_full ==1 & PE_ready ==1)
	begin
		    state <= PE_compute;
	end
	
end

PE_busy:
begin
	if (WB_full ==1 & InB_full ==1 & PE_ready ==1)
	begin
		  state <= PE_compute;
	end
	else if (PE_ready ==0)
	begin
		state <=PE_busy;
	end
end
	
PE_compute:
begin
	if (PE_done ==1)
	begin
		state <= UpdateCounters;
	end
	else
	begin
		state <= PE_compute;
	end
end	


UpdateCounters:
begin
	if (Number_of_MAC_done < Total_Macs)
	begin
		Number_of_MAC_done <= Number_of_MAC_done +1;
		state <= SetAddress;
	end	
	else 
	begin
		Number_of_MAC_done <= 0;
		Number_of_neurons_done <= Number_of_neurons_done +1;
		state <= SetAddress;
	end
end

endcase
end
endmodule
