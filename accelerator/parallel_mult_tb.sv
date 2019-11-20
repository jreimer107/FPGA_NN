module parallel_mult_tb;


reg clk , rst , en; 
reg [15:0] weight_sample;
reg [15:0][15:0] input_neuron;
wire [15:0] out;
integer i;


parallel_mult pm0(.clk(clk), .rst (rst), .input_neuron(input_neuron), .weight_bits(weight_sample), .en(en), .FinalOut(out));


initial
begin
clk =0;
rst = 0;

#10
rst = 1;
en =1;
for(i=0;i<=15;i=i+1)
begin
    input_neuron[i][15:0] <= i[15:0];// + 16'b10011111001111;
    if(i%2 == 0)
        weight_sample[i] = 1'b1;
    else
	weight_sample[i] = 1'b0;
end
end

always 
#5 
clk = !clk;

endmodule