module Mult_tb;


reg clk , rst , weight_sample;
reg [15:0] input_sample , overal_weight;
wire [15:0] out;
reg enable;



Mult Mult0 (.clk (clk) , .reset (rst),  .input_neuron(input_sample), .Weight_bit (weight_sample), .enable(enable), .out(out));



initial
begin
clk =0;
rst = 0;

#10 rst = 1;
enable=1;
input_sample =16'h0801;
overal_weight = 16'b0101010101010101;
weight_sample = overal_weight[0];
#10 weight_sample = overal_weight[1];
#10 weight_sample = overal_weight[2];
#10 weight_sample = overal_weight[3];
#5 weight_sample = overal_weight[4];
#10 weight_sample = overal_weight[5];
#10 weight_sample = overal_weight[6];
#10 weight_sample = overal_weight[7] ;
#10 weight_sample = overal_weight[8];
#10 weight_sample = overal_weight[9];
#10 weight_sample = overal_weight[10];
#10 weight_sample = overal_weight[11];
#10 weight_sample = overal_weight[12];
#10 weight_sample = overal_weight[13];
#10 weight_sample = overal_weight[14];
#10 weight_sample = overal_weight[15];
end

always 
#5 clk = !clk;

endmodule