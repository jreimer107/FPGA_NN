/*
Transmitter
Outputs a "1" until a data byte is loaded then outputs a start bit, the data byte,
and stop bit one bit at a time. Each bit is held for 16 enable signals.
*/
module spart_tx_old(
	input clk,
	input rst,
	input enable,
	input [7:0] data,
	input [1:0] ioaddr,
	input iorw,
	output txd,
	output tbr,
	output reg [7:0] tx_capture
);

reg load, transmitting;
wire [3:0] bit_cnt;
reg [4:0] en_cnt, old_en_cnt;

localparam IDLE = 1'b0;
localparam TRMT = 1'b1;

wire trmt;
assign trmt = (ioaddr == 2'b00 && ~iorw);
wire shift;
assign shift = en_cnt == 5'd16 && old_en_cnt == 5'd15;

always @(posedge clk, posedge rst)
  if(rst)
	old_en_cnt = 5'h00;
  else
	old_en_cnt = en_cnt;

reg state, nxt_state, set_done, clr_done;

cnt_4bit bit_counter(.en({load,shift}), .clk(clk), .rst(rst), .bit_cnt(bit_cnt));

tx_shift_reg shift_register(.en({load,shift}), .clk(clk), .rst(rst), .tx_data(data), .TX(txd));

tx_sr_ff tx_done_flop(.q(tbr), .s(set_done), .r(clr_done), .rst(rst), .clk(clk));

wire [4:0] in;

// Counts the number of enable signals 
assign in = transmitting ? 
		~enable ? en_cnt :
		enable ? (en_cnt == 5'd16) ? 5'h01 : ( en_cnt + 1 ) : 5'h01 : 5'h00;

always @(posedge clk, posedge rst)
  if(rst)
	en_cnt = 5'h00;
  else
	en_cnt = in;

// Test signal - Captures data in buffer
always @(posedge clk, posedge rst)
  if(rst)
	tx_capture <= 8'hFF;
  else if(load)
	tx_capture <= data;

always @(posedge clk, posedge rst) begin
	if(rst)	state <= IDLE;
	else		state <= nxt_state;
end

always @(*) begin
	nxt_state = IDLE;
	load = 0;
	transmitting = 0;
	set_done = 0;
	clr_done = 0;
	
	case(state)
	  IDLE : 
	  begin
		if(trmt)
		begin
			nxt_state = TRMT;
			clr_done = 1;
			load = 1;
			transmitting = 1;
		end
	  end
	  TRMT : 
	  begin
		if(bit_cnt == 4'd10 && shift)
		begin
			nxt_state = IDLE;
			set_done = 1;
			clr_done = 0;
		end else
		begin
			nxt_state = TRMT;
			clr_done = 0;
			transmitting = 1;
		end
	  end
	  default : nxt_state = IDLE;
	endcase
end

endmodule

/*
Counts from zero to ten keeping track of how many bits have been transmitted
*/
module cnt_4bit(en, clk, rst, bit_cnt);

input clk, rst;
input [1:0] en; // {load, shift}
output reg [3:0] bit_cnt;

wire [3:0] in;
reg old;
wire shift;

assign in = ~|en ? bit_cnt :
		~en[1] ? (bit_cnt == 4'd10) ? 4'h0 : ( bit_cnt + 1 ) : 4'h0;

// Edge detector to hold the shift enable high for a single clock cycle
always @(posedge clk, posedge rst)
  if(rst)
	old = 0;
  else
	old = en[0];

assign shift = en[0] && ~old;

always @(posedge clk, posedge rst)
	if(rst)
		bit_cnt <= 4'h0;
	else if(shift)
		bit_cnt <= in;

endmodule

/*
Holds the output high until data is loaded for transmitting then outputs
a start bit, data bit, and stop bit. The register is loaded and shifts
when an enable signal is received
*/
module tx_shift_reg(en, clk, rst, tx_data, TX);

input clk, rst;
input [1:0] en; // {load, shift}
input [7:0] tx_data;

output TX;

wire [9:0] in;
reg [9:0] tx_shft_reg;

reg old;
wire shift;

// Edge detector to hold the shift enable high for a single clock cycle
always @(posedge clk, posedge rst)
  if(rst)
	old = 0;
  else
	old = en[0];

assign shift = en[0] && ~old;

assign in = ~|en ? tx_shft_reg :
		~en[1] ? {1'b1, tx_shft_reg[9:1]} : {1'b1, tx_data, 1'b0};

assign TX = tx_shft_reg[0];

always @(posedge clk, posedge rst)
	if(rst)
		tx_shft_reg <= 10'h3FF;
	else if(en[1] || shift)
		tx_shft_reg <= in;

endmodule

/*
SR Flip Flop
*/
module tx_sr_ff(q, s, r, rst, clk);

input clk, s, r, rst;
output reg q;

always @(posedge clk, posedge rst)
  if(rst)
    q <= 1;
  else if(r)
    q <= 0;
  else if(s)
    q <= 1;
  else
    q <= q;

endmodule



