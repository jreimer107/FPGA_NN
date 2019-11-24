/*
Bus Interface
Receives a chip select signal, I/O address, and read/write signal to input data
to the transmit and baud rate generator modules, or output data from the receive
module and status register.
*/
module bus_intf(
	input clk,
	input rst,
	input rda,
	input tbr,
	input iocs,
	input [1:0] ioaddr,
	input iorw,
	input [7:0] rx_data,
	output [7:0] tx_data,
	output [7:0] br_data,
	inout [7:0] databus,
	output reg [7:0] bus_capture
);

assign databus = iocs && iorw ? 
			ioaddr == 2'b00 ? rx_data :		// receive buffer
			ioaddr == 2'b01 ? {6'b000000, tbr, rda} :	// status reg
			8'bzzzzzzzz : 8'bzzzzzzzz;

assign tx_data = iocs && ~iorw && ioaddr == 2'b00 ? databus : 8'bzzzzzzzz;

assign br_data = iocs && ioaddr[1] ? databus : 8'bzzzzzzzz;

always @(posedge clk, posedge rst)
  if(rst)
	bus_capture <= 8'h00;
  else if(databus == rx_data)
	bus_capture <= databus;

endmodule
