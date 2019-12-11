module SPART_Control(
	input clk,
	input rst,
	input [2:0] ctrl,
	input rxd,
	output txd,
	output sdram_rd_req,
	output reg [15:0] oWord,
	output owordVAL,
	input [15:0] iWord,

	output reg [11:0] rd_req_cnt,
	output reg [11:0] wr_req_cnt,

	output [7:0] SPART_capture,
	output otbr
	);

//wire iocs
//wire iorw;
reg iocs;
reg iorw;
wire rda;
wire tbr;
//wire [1:0] ioaddr;
reg [1:0] ioaddr;
wire [7:0] databus, rx_odata;
wire wordVAL;

// Signals for testing
wire [7:0] rx_data, tx_capture, rx_capture, bus_capture;//, data_capture;
reg [7:0] data_capture;
wire [9:0] DB;

spart spart0(   .clk(clk),
                .rst(!rst),
                .iocs(iocs),
                .iorw(iorw),
                .rda(rda),
                .tbr(tbr),
                .ioaddr(ioaddr),
                .databus(databus),
                .txd(txd),
		.rx_data(rx_data),
		.rx_capture(rx_capture),
		.tx_capture(tx_capture),
		.bus_capture(bus_capture),
		.DB(DB),
                .rxd(rxd)
            );

// assign br_cfg = 2'b01;

/*
driver driver0( .clk(clk),
                .rst(!rst),
                .br_cfg(br_cfg),
                .iocs(iocs),
                .iorw(iorw),
                .rda(rda),
                .tbr(tbr),
                .ioaddr(ioaddr),
		.data_capture(data_capture),
                .databus(databus)
            );
*/

reg [1:0] rxbyte_cnt;
reg [15:0] rxbuffer;

always @(posedge clk, negedge rst)
  if(!rst) begin
    rxbyte_cnt <= 0;
    rxbuffer <= 0;
    //oWord <= 0;
  end
  else if(rda)
    if(rxbyte_cnt == 2 || rxbyte_cnt == 0) begin
      rxbyte_cnt <= 1;
      rxbuffer[7:0] <= rx_capture;
      //oWord[7:0] <= rx_capture;
    end
    else begin
      rxbyte_cnt <= 2;
      rxbuffer[15:8] <= rx_capture;
      //oWord[15:8] <= rx_capture;
    end


assign wordVAL = rxbyte_cnt == 2;

reg wordVAL_old;
always @(posedge clk, negedge rst)
  if(!rst)
    wordVAL_old <= 0;
  else
    wordVAL_old <= wordVAL;

reg old_wordVAL_old;
always @(posedge clk, negedge rst)
  if(!rst)
    old_wordVAL_old <= 0;
  else
    old_wordVAL_old <= wordVAL_old;

assign owordVAL = wordVAL && wordVAL_old && !old_wordVAL_old;//wordVAL && !wordVAL_old && ~ctrl[2];

always @(posedge clk, negedge rst)
  if(!rst)
    wr_req_cnt <= 0;
  else if(owordVAL)
    wr_req_cnt <= wr_req_cnt + 1;

always @(posedge clk, negedge rst)
  if(!rst)
    oWord <= 0;
  else if(wordVAL)
    oWord <= rxbuffer;



////////////////////////////////////////////////////////////////////////////

// New Driver

localparam RX=0, TX=1, IDLE=3;
reg [1:0] state, next_state;

wire [15:0] br_divisor;
assign br_divisor = 325;	// Baud Rate = 9600

reg tx_ready;
reg [7:0] tx_data;
reg [15:0] iWord_old;
reg [1:0] txbyte_cnt;

wire start_tx;
wire got_new_tx_data;

reg [7:0] word_cnt;

reg tbr_old;
always @(posedge clk, negedge rst)
  if(!rst)
    tbr_old <= 0;
  else
    tbr_old <= tbr;

reg old_tx_ctrl;
always @(posedge clk, negedge rst)
  if(!rst)
    old_tx_ctrl <= 0;
  else
    old_tx_ctrl <= ctrl[2];

assign start_tx = ctrl[2] && !old_tx_ctrl;// && tbr (?)

assign sdram_rd_req = (tbr && !tbr_old && txbyte_cnt == 2 && word_cnt < 8) || start_tx;//(tbr && ctrl[2] && !tbr_old && txbyte_cnt != 1) || start_tx;


always @(posedge clk, negedge rst)
  if(!rst)
    iWord_old <= 0;
  else
    iWord_old <= iWord;

assign got_new_tx_data = iWord != iWord_old;//ctrl[2] && (iWord != iWord_old);
/*
always @(posedge clk, negedge rst)
  if(!rst)
    word_cnt <= 0;
  else if(got_new_tx_data)
    word_cnt <= word_cnt + 1;
*/
always @(posedge clk, negedge rst)
  if(!rst)
    rd_req_cnt <= 0;
  else if(sdram_rd_req)
    rd_req_cnt <= rd_req_cnt + 1;

always @(posedge clk, negedge rst)
  if(!rst)
	state <= IDLE;
  else
	state <= next_state;

assign databus = ioaddr == 2'b10 ? br_divisor[7:0] :
		 ioaddr == 2'b11 ? br_divisor[15:8] :
		(ioaddr == 2'b00 && ~iorw) ? tx_data  : 8'hzz;

reg [9:0] clk_cnt;
reg clk_cnt_en;
always @(posedge clk, negedge rst)
  if(!rst)
    clk_cnt_en <= 0;
  else if(&clk_cnt || next_state == TX)
    clk_cnt_en <= 0;
  else if(sdram_rd_req)
    clk_cnt_en <= 1;

always @(posedge clk, negedge rst)
  if(!rst)
    clk_cnt <= 0;
  else if(clk_cnt_en)
    clk_cnt <= clk_cnt + 1;
  else
    clk_cnt <= 0;

reg byte2;

always @(posedge clk, negedge rst)
  if(!rst) begin
    tx_data <= 8'hFF;
    txbyte_cnt <= 0;
    tx_ready <= 0;
    byte2 <= 0;
    word_cnt <= 0;
  end
  else if(next_state == TX)
    tx_ready <= 0;
  else if(((txbyte_cnt == 1 && tbr && !tbr_old) || (tbr_old && (got_new_tx_data || &clk_cnt))) && iWord != 0)
    if(txbyte_cnt == 2 || txbyte_cnt == 0) begin
      txbyte_cnt <= 1;
      tx_data <= iWord[7:0];
      tx_ready <= 1;
      byte2 <= 0;
    end
    else if(txbyte_cnt == 1) begin
      txbyte_cnt <= 2;
      tx_data <= iWord[15:8];
      tx_ready <= 1;
      byte2 <= 1;
      word_cnt <= word_cnt + 1;
    end

always @(*) begin
  next_state = state;
  iocs = 0;
  ioaddr = 2'b01;
  iorw = 1;

  case (state)
	RX : begin
	  iocs = 1;
	  ioaddr = 2'b00;
	  iorw = 1;
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
	  else if(tx_ready) begin//if((tbr && (got_new_tx_data || &clk_cnt)) || (tbr && txbyte_cnt == 1)) begin
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

assign SPART_capture = word_cnt;//tx_data;
assign otbr = byte2;

endmodule
