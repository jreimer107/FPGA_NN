module CropDown(
	input iCLK,
	input iRST,
	input iDVAL,
	input buf_rst,
	input [9:0] iX,
	input [9:0] iY,
	input [11:0] iDATA,
	output reg [7:0] oDATA,
	output reg oDVAL
);

localparam X_init = 27, Y_init = 17, X_max = 614, Y_max = 464, Sx = 21, Sy = 16;

wire in_range;
assign in_range = (iX >= X_init) && (iX <= X_max) && (iY >= Y_init) && (iY <= Y_max);

wire sample_pxl;
assign sample_pxl = in_range && ((iX - X_init) % Sx == 0) && ((iY - Y_init) % Sy == 0);

always_ff @(posedge iCLK, negedge iRST) begin
	if(!iRST) begin
		oDATA <= 8'b0;
		oDVAL <= 1'b0;
	end
	else if(sample_pxl & iDVAL) begin
		oDATA <= iDATA[11:4];
		oDVAL <= 1'b1;
	end
	else begin
		// oDATA <= 8'b0;
		oDVAL <= 1'b0;
	end
end


endmodule