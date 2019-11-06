module Adder_tb;

reg [7:0] in1 , in2;
wire [7:0] sum;


Fixed_adder Add1 (.in1 (in1) , .in2 (in2) , .carry_in (1'b0), .sum(sum), .carry_out (carry));

initial 

begin
in1 = 8'b10101001;
in2 = 8'b11000100;

end

endmodule
