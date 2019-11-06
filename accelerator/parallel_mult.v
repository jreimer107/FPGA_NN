module parallel_mult(
    input clk,
    input rst,
    input [15:0][15:0] input_neuron,
    input [15:0] weight_bits,
    output [15:0]output_neuron[15:0] 
);

Mult mult0(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[0]), .Weight_bit (weight_bits[0]), .out(output_neuron[0]));
Mult mult1(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[1]), .Weight_bit (weight_bits[1]), .out(output_neuron[1]));
Mult mult2(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[2]), .Weight_bit (weight_bits[2]), .out(output_neuron[2]));
Mult mult3(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[3]), .Weight_bit (weight_bits[3]), .out(output_neuron[3]));
Mult mult4(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[4]), .Weight_bit (weight_bits[4]), .out(output_neuron[4]));
Mult mult5(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[5]), .Weight_bit (weight_bits[5]), .out(output_neuron[5]));
Mult mult6(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[6]), .Weight_bit (weight_bits[6]), .out(output_neuron[6]));
Mult mult7(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[7]), .Weight_bit (weight_bits[7]), .out(output_neuron[7]));
Mult mult8(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[8]), .Weight_bit (weight_bits[8]), .out(output_neuron[8]));
Mult mult9(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[9]), .Weight_bit (weight_bits[9]), .out(output_neuron[9]));
Mult mult10(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[10]), .Weight_bit (weight_bits[10]), .out(output_neuron[10]));
Mult mult11(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[11]), .Weight_bit (weight_bits[11]), .out(output_neuron[11]));
Mult mult12(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[12]), .Weight_bit (weight_bits[12]), .out(output_neuron[12]));
Mult mult13(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[13]), .Weight_bit (weight_bits[13]), .out(output_neuron[13]));
Mult mult14(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[14]), .Weight_bit (weight_bits[14]), .out(output_neuron[14]));
Mult mult15(.clk (clk) , .reset (rst),  .input_neuron(input_neuron[15]), .Weight_bit (weight_bits[15]), .out(output_neuron[15]));


endmodule