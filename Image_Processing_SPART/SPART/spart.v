//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    output [7:0] rx_data,
    output [7:0] rx_capture,
    output [7:0] tx_capture,
    output [7:0] bus_capture,
    output [9:0] DB,
    input rxd
    );

wire enable;
wire [7:0] tx_data, br_data;

bus_intf our_bus(
	.clk(clk),
	.rst(rst),
	.rda(rda),
	.tbr(tbr),
	.iocs(iocs),
	.ioaddr(ioaddr),
	.iorw(iorw),
	.rx_data(rx_data),
	.tx_data(tx_data),
	.br_data(br_data),
	.databus(databus),
	.bus_capture(bus_capture)
);

baud_rate_gen our_baud_gen(
	.DB_value(br_data),
	.clk(clk),
	.rst(rst),
	.ioaddr(ioaddr),
	.enable(enable),
	.DB(DB)
	);

spart_tx our_tx(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.data(tx_data),
	.ioaddr(ioaddr),
	.iorw(iorw),
	.txd(txd),
	.tbr(tbr),
	.tx_capture(tx_capture)
);

spart_rx our_rx(
	.clk(clk),
	.rst(rst),
	.enable(enable),
	.rxd(rxd),
	.data(rx_data),
	.rx_capture(rx_capture),
	.rda(rda)
);

endmodule
