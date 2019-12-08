module Img_Proc_FSM(
	input clk, pxlclk, rst_n,

	input iCCD_enable, iStart,
	input iFVAL,
	input iDVAL,
	input [15:0] iDATA,

	output oDmem_wren,
	output reg [6:0] oDmem_addr,
	output [255:0] oDmem_data,
	output reg oCCD_Done
);

// Buffer FVAL to detect rising edge (new frame)
reg FVAL_buf;
wire frame_start = iFVAL & !FVAL_buf;
always_ff @(posedge pxlclk, negedge rst_n)
	if (!rst_n)
		FVAL_buf <= 0;
	else
		FVAL_buf <= iFVAL;


// FSM state control
typedef enum {IDLE, WAIT, CAPTURE, SEND_LAST} state_t;
state_t state, next_state;
always_ff @(posedge clk, negedge rst_n)
	if (!rst_n)
		state <= IDLE;
	else
		state <= next_state;

// Pixel count register
reg [9:0] pxl_cnt;
wire [3:0] pxl_index = pxl_cnt % 16;
always_ff (@posedge pxlclk, negedge rst_n) begin
	if (!rst_n)
		pxl_cnt <= 0;
	else begin
		pxl_cnt <= pxl_cnt;
		if (state == CAPTURE)
			if (iDVAL) pxl_cnt <= pxl_cnt + 1;
		else pxl_cnt <= 0;
	end
end

// Dmem write address incrementation and reset
always_ff @(posedge pxlclk, negedge rst_n)
	if (!rst_n)
		dmem_wraddr <= 0;
	else begin
		dmem_wraddr <= dmem_wraddr;
		if ((state == CAPTURE & pxl_cnt != 0 & pxl_index == 0) || 
			state == SEND_LAST)
			dmem_wraddr <= dmem_wraddr + 1;
		else if (state == IDLE)
			dmem_wraddr <= 0;
	end

		// if (state == CAPTURE)
		// 	if (pxl_cnt != 0 & pxl_index == 0) begin
		// 			dmem_wraddr <= dmem_wraddr + 1;
		// else if (state == SEND_LAST)
		// 	dmem_wraddr <= dmem_wraddr + 1;
		// else
		// 	dmem_wraddr <= 0;


// oCCD_Done FF
always_ff (@ posedge clk, negedge rst_n) begin
	if (!rst_n)
		oCCD_Done <= 1'b0;
	else begin
		oCCD_Done <= oCCD_Done;
		if (iCCD_enable)
			if (state == SEND_LAST)
				oCCD_Done <= 1'b1;
			else if (state == WAIT)
				oCCD_Done <= 1'b0;
		else
			oCCD_Done <= 1'b0;
	end


always_comb begin
	next_state = IDLE;
	case(state)
		// Wait for button press and enable signal
		IDLE: begin
			if (iCCD_enable & iStart)
				next_state = WAIT;
		end

		// Wait for next image to start
		WAIT: begin
			next_state = WAIT;
			if (frame_start) begin
				next_state = CAPTURE;
			end
		end

		// Capture 28x28 image emitted by pipeline
		CAPTURE: begin
			next_state = CAPTURE;
			if (iDVAL)
				dmem_wrdata[pxl_index] = iDATA;
			if (pxl_cnt != 0 & pxl_index == 0)
				dmem_wren = 1;
			if (pxl_cnt == 783)
				next_state = SEND_LAST;
		end

		// 783 not divisible by 16, so send last batch
		SEND_LAST: begin
			dmem_wren = 1;
			next_state = IDLE;
		end

		default: next_state = IDLE;
	endcase
end

endmodule