module Mult_tb;


reg clk , rst , weight_sample;
reg [7:0] input_sample;
wire [7:0] out;



Mult Mult0 (.clk (clk) , .reset (rst),  .input_neuron(input_sample), .Weight_bit (weight_sample), .out(out));



initial
begin
clk =0;
rst = 0;

#10 rst = 1;
input_sample =16'b01101001;
weight_sample = 1'b1;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b0;
#10 weight_sample = 1'b1;
#200 weight_sample = 1'b0;
end

always 
#5 clk = !clk;

endmodule