module Img_Proc_FSM(
	input pxlclk, rst_n,

	input iCCD_enable, iCCD_start,
	input iFVAL,
	input iDVAL,
	input [15:0] iDATA,

	output oDmem_wren,
	output [6:0] oDmem_addr,
	output [255:0] oDmem_data,
	// output [15:0] oDmem_data [15:0],
	output oCCD_done
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
state_t state;

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
		dmem_addr <= 7'b0;
		pxl_cnt <= 10'b0;
	end
	else begin
		case(state)
			// Wait for button press and enable signal
			IDLE: begin
				pixels <= '{default:0};
				ccd_done <= 1'b0;
				dmem_addr <= 7'b0;
				dmem_addr <= 1'b0;
				pxl_cnt <= 10'b0;
				if (iCCD_enable & iCCD_start)
					state <= WAIT;
			end

			// Wait for next image to start
			WAIT: begin
				dmem_addr <= 7'b0;
				dmem_wren <= 1'b0;
				ccd_done <= 1'b0;
				pxl_cnt <= 10'b0;
				if (frame_start)
					state <= CAPTURE;
				else
					state <= WAIT;
			end

			// Capture 28x28 image emitted by pipeline
			CAPTURE: begin
				if (iDVAL) begin
					pixels[pxl_index] <= iDATA;
					pxl_cnt <= pxl_cnt + 1;
					dmem_wren <= 1'b0;
					if (pxl_index == 4'hf) begin
						dmem_wren <= 1;
						dmem_addr <= dmem_addr + 1;
					end
					if (pxl_cnt == 783) begin
						dmem_wren <= 1;
						dmem_addr <= dmem_addr + 1;
						state <= SEND_LAST;
						pixels[pxl_index + 1] <= 16'h0;
					end
				end
				else begin
					pxl_cnt <= pxl_cnt;
					dmem_addr <= 7'b0;
					dmem_wren <= 1'b0;
					ccd_done <= 1'b0;
				end
			end

			// 783 not divisible by 16, so send last batch
			SEND_LAST: begin
				state <= IDLE;
				pxl_cnt <= 10'b0;
				dmem_addr <= 7'b0;
				dmem_wren <= 1'b0;
				ccd_done <= 1'b1;
				pixels <= '{default:0};
			end

			default: state <= IDLE;
		endcase
	end
end

assign pxl_index = pxl_cnt & 4'hf;
assign oDmem_wren = dmem_wren;
assign oDmem_addr = dmem_addr;
assign oCCD_done = ccd_done;
assign oDmem_data = {pixels[15], pixels[14], pixels[13], pixels[12],
							pixels[11], pixels[10], pixels[9], pixels[8], 
							pixels[7], pixels[6], pixels[5], pixels[4],
							pixels[3], pixels[2], pixels[1], pixels[0]};

endmodule