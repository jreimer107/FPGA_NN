module FSM2VGA(
	input iCLK, iRST,

	input   [255:0]  iDATA,
	input           iDVAL,

	output  [11:0]  ovgaDATA,
	output          ovgaDVAL
);
reg [783:0][15:0] cropdown;
reg [9:0] sample_cnt;
reg [19:0] TARG_cnt;

always_ff @(posedge iCLK, negedge iRST)
	if(!iRST)
		cropdown <= '{default:0};
	else if(TARG_cnt == 307200)
		cropdown <= '{default:0};
	else if(iDVAL && sample_cnt < 784)
		cropdown <= {iDATA, cropdown[783:16]};

always_ff @(posedge iCLK, negedge iRST)
	if(!iRST)
		sample_cnt <= '{default:0};
	else if(TARG_cnt == 307200)
		sample_cnt <= '{default:0};
	else if(iDVAL && sample_cnt < 784)
		sample_cnt <= sample_cnt + 16;

// assign oSC = {cropdown[783],cropdown[0]};

reg [6:0] clk_cnt;
always @(posedge iCLK, negedge iRST)
	if(!iRST)
		clk_cnt <= 0;
	else if(sample_cnt == 0)
		clk_cnt <= 0;
	else if(sample_cnt >= 784)
		clk_cnt <= clk_cnt + 1;

wire modDVAL;

always_ff @(posedge iCLK, negedge iRST)
	if(!iRST)
		TARG_cnt <= 0;
	else if(sample_cnt == 0)
		TARG_cnt <= 0;
	else if(modDVAL) begin
		TARG_cnt <= TARG_cnt + 1;
	end

assign modDVAL = &clk_cnt && TARG_cnt <= 307200;

wire [9:0] oX, oY;
assign oX = TARG_cnt % 640;
assign oY = TARG_cnt / 640;

assign ovgaDVAL = modDVAL;
assign ovgaDATA = {cropdown[(oX % 28)+(28*(oY%28))][7:0], 4'h0};//(oX < 28 && oY < 28) ? cropdown[(oX + 28*oY)] : 0;
// assign ovgaDATA = (oX < 28 && oY < 28) ? cropdown[(oX + 28*oY)] : 0;


endmodule
