module Mult_tb;


reg clk , rst , weight_sample;
reg [15:0] input_sample;
wire [15:0] out;
reg enable;



Mult Mult0 (.clk (clk) , .reset (rst),  .input_neuron(input_sample), .Weight_bit (weight_sample), .enable(enable), .out(out));



initial
begin
clk =0;
rst = 0;

#10 rst = 1;
enable=1;
input_sample =16'b0001100101100000;
weight_sample = 1'b1;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b1;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b1;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b1;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#200 weight_sample = 1'b0;
end

always 
#5 clk = !clk;

endmodule