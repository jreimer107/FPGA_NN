module fifo ( input clk,
	input Rd_Req,
	input [15:0] in_data,
	output [15:0] out_data);



reg [15:0] out_data_reg;
always @(clk)
begin
	if (Rd_Req)
	out_data_reg <= in_data;
	else
	out_data_reg <=16'hzzzz;
end


assign out_data = out_data_reg;
endmodule
