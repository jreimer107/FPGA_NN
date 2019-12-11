module Img_Proc_FSM(
	input pxlclk, rst_n,

	input iCCD_enable, iCCD_start,
	input iFVAL,
	input iDVAL,
	input [15:0] iDATA,

	output oDmem_wren,
	output reg [6:0] oDmem_addr,
	output [255:0] oDmem_data,
	// output [15:0] oDmem_data [15:0],
	output reg [1:0] state,
	output oCCD_done,
	output frame_val
);

// Buffer FVAL to detect rising edge (new frame)
reg FVAL_buf;
// wire frame_start = iFVAL & !FVAL_buf;
always_ff @(posedge pxlclk, negedge rst_n)
	if (!rst_n)
		FVAL_buf <= 0;
	else
		FVAL_buf <= iFVAL & !FVAL_buf;

reg DVAL_buf;
always_ff @(posedge pxlclk, negedge rst_n)
	if(!rst_n)
		DVAL_buf <= 0;
	else
		DVAL_buf <= iDVAL;

reg ccd_start_buf;
always_ff @(posedge pxlclk, negedge rst_n)
	if(!rst_n)
		ccd_start_buf <= 1'b0;
	else
		ccd_start_buf <= iCCD_start;

assign frame_val = FVAL_buf;

// FSM state control
// typedef enum {IDLE, WAIT, CAPTURE, SEND_LAST} state_t;
localparam IDLE = 2'h0, WAIT = 2'h1, CAPTURE = 2'h2, SEND_LAST = 2'h3;
// reg [1:0] state;

reg [15:0] pixels [15:0];
reg dmem_wren;
reg [6:0] dmem_addr;
reg ccd_done;

reg [9:0] pxl_cnt;
wire [3:0] pxl_index;

always_ff @(posedge pxlclk, negedge rst_n) begin
	if (!rst_n) begin
		ccd_done <= 1'b0;
		pixels <= '{default:0};
		state <= IDLE;
		dmem_wren <= 1'b0;
		pxl_cnt <= 10'b0;
	end
	else begin
		case(state)
			// Wait for button press and enable signal
			IDLE: begin
				pixels <= '{default:0};
				dmem_wren <= 1'b0;
				pxl_cnt <= 10'b0;
				if (iCCD_enable & ccd_start_buf) begin
					state <= WAIT;
					ccd_done <= 1'b0;
				end
			end

			// Wait for next image to start
			WAIT: begin
				state <= WAIT;
				if (FVAL_buf) begin
					dmem_wren <= 1'b0;
					pxl_cnt <= 10'b0;
					state <= CAPTURE;
				end
			end

			// Capture 28x28 image emitted by pipeline
			CAPTURE: begin
				if (DVAL_buf) begin
					pixels[pxl_index] <= iDATA;
					pxl_cnt <= pxl_cnt + 1;
					dmem_wren <= 1'b0;
					if (pxl_index == 4'hf) begin
						dmem_wren <= 1;
					end
					if (pxl_cnt == 783) begin
						dmem_wren <= 1;
						state <= SEND_LAST;
					end
				end
				else begin
					pxl_cnt <= pxl_cnt;
					dmem_wren <= 1'b0;
					ccd_done <= 1'b0;
				end
			end

			// 783 not divisible by 16, so send last batch
			SEND_LAST: begin
				state <= IDLE;
				pxl_cnt <= 10'b0;
				dmem_wren <= 1'b0;
				ccd_done <= 1'b1;
				pixels <= '{default:0};
			end

			default: state <= IDLE;
		endcase
	end
end

always_ff @(posedge pxlclk, negedge rst_n)
	if(!rst_n)
		oDmem_addr <= 7'h0;
	else if(state == IDLE)
		oDmem_addr <= 7'h0;
	else
		oDmem_addr <= dmem_wren ? oDmem_addr + 7'h1 : oDmem_addr;

assign pxl_index = pxl_cnt & 4'hf;
assign oDmem_wren = dmem_wren;
assign oCCD_done = ccd_done;
assign oDmem_data = {pixels[15], pixels[14], pixels[13], pixels[12],
							pixels[11], pixels[10], pixels[9], pixels[8], 
							pixels[7], pixels[6], pixels[5], pixels[4],
							pixels[3], pixels[2], pixels[1], pixels[0]};

endmodule