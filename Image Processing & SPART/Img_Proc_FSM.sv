module Img_Proc_FSM(
	input clk, pxlclk, rst_n,

	input iCCD_enable, iCCD_start,
	input iFVAL,
	input iDVAL,
	input [15:0] iDATA,

	output reg oDmem_wren,
	output reg [6:0] oDmem_addr,
	output reg [15:0] oDmem_data [15:0],
	output reg oCCD_done
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
always_ff @(posedge pxlclk, negedge rst_n) begin
	if (!rst_n)
		pxl_cnt <= 0;
	else begin
		pxl_cnt <= pxl_cnt;
		if (state == CAPTURE) begin
			if (iDVAL) 
				pxl_cnt <= pxl_cnt + 1;
		end
		else 
			pxl_cnt <= 0;
	end
end

// Dmem write address incrementation and reset
always_ff @(posedge pxlclk, negedge rst_n)
	if (!rst_n)
		oDmem_addr <= 0;
	else begin
		oDmem_addr <= oDmem_addr;
		if ((state == CAPTURE & pxl_index == 4'hf) || 
			state == SEND_LAST)
			oDmem_addr <= oDmem_addr + 1;
		else if (state == IDLE)
			oDmem_addr <= 0;
	end

		// if (state == CAPTURE)
		// 	if (pxl_cnt != 0 & pxl_index == 0) begin
		// 			oDmem_addr <= oDmem_addr + 1;
		// else if (state == SEND_LAST)
		// 	oDmem_addr <= oDmem_addr + 1;
		// else
		// 	oDmem_addr <= 0;


// oCCD_done FF
// always_ff @(posedge clk, negedge rst_n)
// 	if (!rst_n)
// 		oCCD_done <= 1'b0;
// 	else begin
// 		oCCD_done <= oCCD_done;
// 		if (iCCD_enable)
// 			if (state == SEND_LAST)
// 				oCCD_done <= 1'b1;
// 			else if (state == WAIT)
// 				oCCD_done <= 1'b0;
// 		else
// 			oCCD_done <= 1'b0;
// 	end

reg [15:0] pixels [15:0];
always_comb begin
	if (!rst_n) begin
		oCCD_done = 1'b0;
		// oDmem_addr = 0;
	end

	// oDmem_addr = oDmem_addr;
	oCCD_done = oCCD_done;
	next_state = IDLE;
	oDmem_wren = 1'b0;
	pixels = pixels;

	case(state)
		// Wait for button press and enable signal
		IDLE: begin
			pixels = '{default:0};
			if (iCCD_enable & iCCD_start) begin
				next_state = WAIT;
				oCCD_done = 1'b0;
			end
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
				pixels[pxl_index] = iDATA;
			if (pxl_index == 4'hf)
				oDmem_wren = 1;
			if (pxl_cnt == 783)
				next_state = SEND_LAST;
		end

		// 783 not divisible by 16, so send last batch
		SEND_LAST: begin
			oDmem_wren = 1;
			next_state = IDLE;
			oCCD_done = 1'b1;
		end

		default: next_state = IDLE;
	endcase
end


// Need to do register bypassing on the last pixel so it gets there in time
always_comb begin
	oDmem_data = pixels;
	oDmem_data[pxl_index] = iDATA;
end

// assign oDmem_data = {iDATA, pixels[14:0]};
// assign oDmem_data = pxl_index == 4'h0 ? {pixels[15:1], iDATA} :
// 					pxl_index == 4'hf ? {iDATA, pixels[14:0]} :
// 					{pixels[15 : pxl_index + 1], iDATA, pixels[pxl_index - 1 : 0]};

endmodule