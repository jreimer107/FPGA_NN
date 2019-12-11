module Adder_tb;

reg [15:0] in1 , in2;
wire [15:0] sum;


Fixed_adder Add1 (.in1 (in1) , .in2 (in2) , .carry_in (1'b0), .sum(sum), .carry_out (carry));

initial 

begin
in1 = 16'h7fff;
in2 = 16'h7089;

end

endmodule
