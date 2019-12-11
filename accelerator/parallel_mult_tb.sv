module parallel_mult_tb;


reg clk , rst , en; 
reg [15:0] weight_sample , overal_weight;
reg [15:0][15:0] input_neuron;
wire [15:0] Finalout;
integer i;


parallel_mult pm0(.clk(clk), .rst (rst), .input_neuron(input_neuron), .weight_bits(weight_sample), .en(en), .FinalOut(Finalout));


initial
begin
clk =0;
rst = 0;


#20 rst = 1;
en =1;
for(i=0;i<=15;i=i+1)
begin
    input_neuron[i][15:0] <= 16'hA800;
end

overal_weight = 16'h0400;//b0000010000000000;


for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[0];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[1];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[2];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[3];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[4];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[5];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[6];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[7];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[8];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[9];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[10];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[11];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[12];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[13];
end


#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[14];
end

#10
for(i=0;i<=15;i=i+1)
begin
	weight_sample[i] = overal_weight[15];
end



/*for(i=0;i<=15;i=i+1)
begin
if(i%2 == 0)
	weight_sample[i] = 1'b1;
else
	weight_sample[i] = 1'b0;
end */


end

always 
#5 
clk = !clk;

endmodule