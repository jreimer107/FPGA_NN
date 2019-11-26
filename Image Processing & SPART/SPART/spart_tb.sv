module spart_tb();

reg clk, rst;
reg [1:0] br_cfg;

wire rxd, txd, iocs, iorw, rda, tbr;
wire [7:0] databus, tb_databus;
wire [1:0] ioaddr;

reg [11:0] testvector[20:0];
reg tb_iocs, tb_iorw;
reg [1:0] tb_ioaddr;
reg [7:0] tb_data, result, expected;

wire tb_rda, tb_tbr;

integer i;

spart spart0(   .clk(clk),
                .rst(rst),
                .iocs(tb_iocs),
                .iorw(tb_iorw),
                .rda(tb_rda),
                .tbr(tb_tbr),
                .ioaddr(tb_ioaddr),
                .databus(tb_databus),
                .txd(rxd),
                .rxd(txd)
            );

spart dut_spart1(.clk(clk),
                .rst(rst),
                .iocs(iocs),
                .iorw(iorw),
                .rda(rda),
                .tbr(tbr),
                .ioaddr(ioaddr),
                .databus(databus),
                .txd(txd),
                .rxd(rxd)
            );

driver dut_driver(.clk(clk),
                .rst(rst),
                .br_cfg(br_cfg),
                .iocs(iocs),
                .iorw(iorw),
                .rda(rda),
                .tbr(tbr),
                .ioaddr(ioaddr),
                .databus(databus)
            );

assign tb_databus = tb_data;

initial begin

  clk = 0;
  rst = 1;
  br_cfg = 2'b11;

  #100;
  
  $readmemb("sampletext.txt", testvector);

  @(negedge clk);
  rst = 0;

  for(i=0; i<20; i=i+1) begin
	{tb_iocs, tb_iorw, tb_ioaddr, tb_data} = testvector[i];
	if(tb_ioaddr == 2'b00 && ~tb_iorw) begin
//		while(~tb_tbr) begin  end
		expected = tb_data;
		@(negedge clk)
		tb_ioaddr = 2'b01;
		@(posedge tb_rda)
		tb_ioaddr = 2'b00;
		tb_iorw = 1;
  		result = tb_data;
		if(result != expected) begin
		  $display("FAIL: expected %b, but got %b", expected, result);
		  $stop;
  		end
		else
		  $display("CORRECT: expected %b, and got %b", expected, result);
	end
	repeat (2) begin
		@(negedge clk);
	end
	$display("iocs: %b, iorw: %b, ioaddr: %b, data: %b", tb_iocs, tb_iorw, tb_ioaddr, tb_data);
  end

  $stop;
end

always
  #20 clk <= ~ clk;

endmodule
