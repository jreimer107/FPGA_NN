module Accel_tb;


integer i;
reg clk , reset, busrdwr, CPUEnable, DVAL;
reg [15:0] in_data, data_bus;
reg [15:0] [15:0] BRAM_data;
wire [15:0] out_addr_current, output_neuron, DRAMdata, BRAM_Addr_In;
Accelerator Accl1(
	.clk(clk),
	.reset(reset),
	.DRAMdata(DRAMdata),
	.data_bus(data_bus),
	.BRAM_data(BRAM_data),
	.busrdwr(busrdwr),
	.CPUEnable(CPUEnable),
	.DVAL(DVAL),
	.BRAM_Addr_In(BRAM_Addr_In),
	.output_neuron(output_neuron),
	.out_addr_current(out_addr_current),
	.Rd_BRAM_current(Rd_BRAM_current),
	.Wr_BRAM_current(Wr_BRAM_current),
	.SRAM_RdReq(SRAM_RdReq),
	.cpu_neuron_done(cpu_neuron_done)
);

fifo f1(.clk(clk),
	.Rd_Req(SRAM_RdReq),
	.in_data(in_data),
	.out_data(DRAMdata)
);


initial 
begin
clk <= 0;
reset <= 0;
#20 reset <=1;
CPUEnable <=1;
#10 busrdwr <=1;
data_bus <= 16'h0000;
#10 data_bus <= 16'h0010;
#10 data_bus <= 16'h0011;
#10 data_bus <= 16'h0010; //input neurons
#10 data_bus <= 16'h0001; //#output neurons
#10 busrdwr <=0;
#10 DVAL <=1;
#10 DVAL <= 0;
for(i=0;i<=15;i=i+1)
begin
   BRAM_data[i][15:0] <= i[15:0] + 16'b10011111001111;
end
in_data <= 16'h0800;
#10 in_data <= 16'h0801;
#10 in_data <= 16'h0802;
#10 in_data <= 16'h0803;
#10 in_data <= 16'h0804;
#10 in_data <= 16'h0805;
#10 in_data <= 16'h0806;
#10 in_data <= 16'h0807;
#10 in_data <= 16'h0808;
#10 in_data <= 16'h0809;
#10 in_data <= 16'h080A;
#10 in_data <= 16'h080B;
#10 in_data <= 16'h080C;
#10 in_data <= 16'h080D;
#10 in_data <= 16'h080E;
#10 in_data <= 16'h080F;

end

always #5 clk = ~clk;

endmodule
