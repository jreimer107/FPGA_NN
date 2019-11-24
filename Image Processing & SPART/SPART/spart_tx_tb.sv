module spart_tx_tb();

reg clk, rst, enable, iorw;
reg [7:0] tx_data;
reg [1:0] ioaddr;

wire TXD, TBR;

//UART_tx transmitter(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(TX), .tx_done(tx_done));
spart_tx transmitter(.clk(clk), .rst(rst), .enable(enable), .data(tx_data), .ioaddr(ioaddr), .iorw(iorw), .txd(TXD), .tbr(TBR));

initial begin

	clk = 0;
	rst = 1;
	iorw = 1;
	enable = 0;

	ioaddr = 2'b10;
	tx_data = 8'h00;
	@(posedge clk);
	@(negedge clk);
	rst = 0;
	iorw = 0;
	ioaddr = 2'b00;

	@(negedge TBR);
	ioaddr = 2'b11;

	@(posedge TBR);

	repeat (5) begin
		@(posedge clk);
		@(negedge clk);
	end

	ioaddr = 2'b00;
	tx_data = 8'h2c;

	@(negedge TBR);
	ioaddr = 2'b11;

	@(posedge TBR);

	repeat (5) begin
		@(posedge clk);
		@(negedge clk);
	end

	ioaddr = 2'b00;
	tx_data = 8'h9F;

	@(posedge TBR);
	$stop;

end

always @(transmitter.bit_cnt) $display("bit = %d, tx_data = %b, shift_reg = %b, TX = %b", transmitter.bit_cnt, tx_data, transmitter.shift_register, TXD);

always
	#20 clk <= ~clk;

always begin
	repeat (325) begin
		@(negedge clk);
	end
	enable <= 1;
	@(negedge clk);
	enable <= 0;
end

endmodule
