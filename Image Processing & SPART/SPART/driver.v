/*
Driver
Contains FSM to drive the databus. Data received from SPART is then sent to SPART
to transmit. The baud rate divisor is also provided to SPART by the driver.
*/
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output reg iocs,
    output reg iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    output reg [7:0] data_capture,
    inout [7:0] databus
    );

localparam RX=0, TX=1, BR_low=2, BR_high=3, IDLE=4;
reg [2:0] state, next_state;

reg [15:0] br_divisor, br_old, br_curr;

reg [7:0] data;

reg new_divisor;
reg tx_ready;
reg [7:0] tx_data;

always @(posedge clk, posedge rst)
  if(rst)
	state <= IDLE;
  else
	state <= next_state;

assign databus = ioaddr == 2'b10 ? br_divisor[7:0] :
		 ioaddr == 2'b11 ? br_divisor[15:8] :
		(ioaddr == 2'b00 && ~iorw) ? tx_data  : 8'hzz;

always @(posedge clk, posedge rst)
  if(rst) begin
	br_old = br_divisor;
	br_curr = br_divisor;
  end
  else begin
	br_old = br_curr;
	br_curr = br_divisor;
  end

// Determines if there is a new baud rate divisor that needs to be sent to the SPART module
always @(posedge clk, posedge rst)
  if(rst)
	new_divisor <= 1;
  else if(br_curr != br_old)
	new_divisor <= 1;
  else if(state == BR_high)
	new_divisor <= 0;

// If data has been received it can then be transmitted
always @(posedge clk, posedge rst)
  if(rst)
	tx_ready <= 0;
  else if(state == RX)
	tx_ready <= 1;
  else if(state == TX)
	tx_ready <= 0;

always @(posedge clk, posedge rst)
  if(rst)
	tx_data <= 8'hFF;
  else if(state == RX)
	tx_data <= data;

// Test signal - Captures data in buffer
always @(posedge clk, posedge rst)
  if(rst)
	data_capture <= 8'hFF;
  else if(next_state == TX)
	data_capture <= tx_data;

always @(*) begin
  next_state = state;
  data = 8'hFF;
  iocs = 0;
  ioaddr = 2'b01;
  iorw = 1;

  case (state)
	RX : begin
	  iocs = 1;
	  ioaddr = 2'b00;
	  iorw = 1;
	  data = databus;
	  next_state = IDLE;
	end
	BR_low : begin
	  iocs = 1;
	  ioaddr = 2'b10;
	  next_state = BR_high;
	end
	BR_high : begin
	  iocs = 1;
	  ioaddr = 2'b11;
	  next_state = IDLE;
	end
	TX : begin
	  iocs = 1;
	  ioaddr = 2'b00;
	  iorw = 0;
	  next_state = IDLE;
	end
	IDLE : begin
	  iocs = 0;
	  ioaddr = 2'b01;
	  if(rda) begin
		next_state = RX;
		iocs = 1;
	  end
	  else if(new_divisor) begin
		next_state = BR_low;
		iocs = 1;
	  end
	  else if(tbr && tx_ready) begin
		next_state = TX;
		iocs = 1;
	  end
	  else
		next_state = IDLE;
	end
	default : begin
	  next_state = IDLE;
	end
  endcase
end

// Hard-coded baud rate divisor values
always@(*) begin
  case (br_cfg)
        2'b00 : begin // 4800
            br_divisor = 16'd650;
        end

	2'b01 : begin // 9600
            br_divisor = 16'd325;
        end

        2'b10 : begin // 19200
            br_divisor = 16'd162;
        end

        2'b11 : begin // 38400
            br_divisor = 16'd80;
        end

        default : begin
            br_divisor = 16'd325;
        end

  endcase
end

endmodule
