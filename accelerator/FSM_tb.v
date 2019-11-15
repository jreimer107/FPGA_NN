module FSM_tb;


reg clk , rst, DVAL, start, enable;
reg [15:0] BaseAddr_W, BaseAddr_in, input_neurons, output_neurons;
wire [15:0] Waddress_current, Inaddress_current;


Accelerator_FSM FSM1(.clk (clk), .rst (rst) , .BaseAddr_W(BaseAddr_W), .BaseAddr_in (BaseAddr_in), .total_output_neurons (output_neurons) , 
		      .total_input_neurons(input_neurons), .DVAL(DVAL), .accelerator_start(start), .Enable (enable),
		      .Waddress_current(Waddress_current), .Inaddress_current(Inaddress_current), .neuron_done (neuron_done));




initial
begin
clk <=0;
rst <=1;
start <=0;
DVAL <=0;

BaseAddr_W <=16'h1111;
BaseAddr_in <= 16'h0000;
output_neurons <= 116'h0010;
input_neurons <=16'h0020;
#20 rst <=0;
#20 enable <=1;
#20 start <=1 ;

#20 DVAL<=1;
#320 DVAL <=0;

#40 DVAL <=1;
#360 DVAL <=0;
enable <= 0;

end

always 
#10 clk = !clk;

endmodule