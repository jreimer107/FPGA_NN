module parallel_mult(
    input clk,
    input rst,
    input [15:0][15:0] input_neuron,
    input [15:0] weight_bits,
    input en,
    output [15:0] FinalOut
   
);


wire  [15:0][15:0] output_neuron;
wire [15:0] sum_1_1, sum_1_2, sum_1_3, sum_1_4, sum_1_5, sum_1_6, sum_1_7, sum_1_8, sum_2_1 , sum_2_2, sum_2_3, sum_2_4, sum_3_1, sum_3_2, sum_4_1;


Mult mult0(.clk (clk) , .reset (rst), .enable(en),  .input_neuron(input_neuron[0]), .Weight_bit (weight_bits[0]), .out(output_neuron[0]));
Mult mult1(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[1]), .Weight_bit (weight_bits[1]), .out(output_neuron[1]));
Mult mult2(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[2]), .Weight_bit (weight_bits[2]), .out(output_neuron[2]));
Mult mult3(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[3]), .Weight_bit (weight_bits[3]), .out(output_neuron[3]));
Mult mult4(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[4]), .Weight_bit (weight_bits[4]), .out(output_neuron[4]));
Mult mult5(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[5]), .Weight_bit (weight_bits[5]), .out(output_neuron[5]));
Mult mult6(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[6]), .Weight_bit (weight_bits[6]), .out(output_neuron[6]));
Mult mult7(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[7]), .Weight_bit (weight_bits[7]), .out(output_neuron[7]));
Mult mult8(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[8]), .Weight_bit (weight_bits[8]), .out(output_neuron[8]));
Mult mult9(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[9]), .Weight_bit (weight_bits[9]), .out(output_neuron[9]));
Mult mult10(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[10]), .Weight_bit (weight_bits[10]), .out(output_neuron[10]));
Mult mult11(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[11]), .Weight_bit (weight_bits[11]), .out(output_neuron[11]));
Mult mult12(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[12]), .Weight_bit (weight_bits[12]), .out(output_neuron[12]));
Mult mult13(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[13]), .Weight_bit (weight_bits[13]), .out(output_neuron[13]));
Mult mult14(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[14]), .Weight_bit (weight_bits[14]), .out(output_neuron[14]));
Mult mult15(.clk (clk) , .reset (rst), .enable(en), .input_neuron(input_neuron[15]), .Weight_bit (weight_bits[15]), .out(output_neuron[15]));


Fixed_adder Add1_1 (.in1 (output_neuron[0]) , .in2 (output_neuron[1]) , .carry_in (1'b0), .sum(sum_1_1), .carry_out (carry_1_1));
Fixed_adder Add1_2 (.in1 (output_neuron[2]) , .in2 (output_neuron[3]) , .carry_in (carry_1_1), .sum(sum_1_2), .carry_out (carry_1_2));
Fixed_adder Add1_3 (.in1 (output_neuron[4]) , .in2 (output_neuron[5]) , .carry_in (carry_1_2), .sum(sum_1_3), .carry_out (carry_1_3));
Fixed_adder Add1_4 (.in1 (output_neuron[6]) , .in2 (output_neuron[7]) , .carry_in (carry_1_3), .sum(sum_1_4), .carry_out (carry_1_4));
Fixed_adder Add1_5 (.in1 (output_neuron[8]) , .in2 (output_neuron[9]) , .carry_in (carry_1_4), .sum(sum_1_5), .carry_out (carry_1_5));
Fixed_adder Add1_6 (.in1 (output_neuron[10]) , .in2 (output_neuron[11]) , .carry_in (carry_1_5), .sum(sum_1_6), .carry_out (carry_1_6));
Fixed_adder Add1_7 (.in1 (output_neuron[12]) , .in2 (output_neuron[13]) , .carry_in (carry_1_6), .sum(sum_1_7), .carry_out (carry_1_7));
Fixed_adder Add1_8 (.in1 (output_neuron[14]) , .in2 (output_neuron[15]) , .carry_in (carry_1_7), .sum(sum_1_8), .carry_out (carry_1_8));

Fixed_adder Add2_1 (.in1 (sum_1_1) , .in2 (sum_1_2) , .carry_in (carry_1_8), .sum(sum_2_1), .carry_out (carry_2_1));
Fixed_adder Add2_2 (.in1 (sum_1_3) , .in2 (sum_1_4) , .carry_in (carry_2_1), .sum(sum_2_2), .carry_out (carry_2_2));
Fixed_adder Add2_3 (.in1 (sum_1_5) , .in2 (sum_1_6) , .carry_in (carry_2_2), .sum(sum_2_3), .carry_out (carry_2_3));
Fixed_adder Add2_4 (.in1 (sum_1_7) , .in2 (sum_1_8) , .carry_in (carry_2_3), .sum(sum_2_4), .carry_out (carry_2_4));


Fixed_adder Add3_1(.in1 (sum_2_1) , .in2 (sum_2_2) , .carry_in (carry_2_4), .sum(sum_3_1), .carry_out (carry_3_1));
Fixed_adder Add3_2(.in1 (sum_2_3) , .in2 (sum_2_4) , .carry_in (carry_3_1), .sum(sum_3_2), .carry_out (carry_3_2));

Fixed_adder Add4_1(.in1 (sum_3_1) , .in2 (sum_3_2) , .carry_in (carry_3_2), .sum(sum_4_1), .carry_out (carry_4_1));

Fixed_adder Add_final(.in1 (sum_4_1) , .in2 (16'h00) , .carry_in (carry_4_1), .sum(FinalOut), .carry_out (FinalCarry));



endmodule