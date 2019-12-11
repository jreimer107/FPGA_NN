module Img_Proc_FSM_tb();

reg clk, pxlclk, rst_n;

reg enable, start;
reg FVAL, DVAL;
reg [15:0] DATA;

wire dmem_wren;
wire [6:0] dmem_addr;
wire [15:0] dmem_data [15:0];
wire done;

Img_Proc_FSM DUT(
    // .clk(clk),
    .pxlclk(pxlclk),
    .rst_n(rst_n),

    .iCCD_enable(enable),
    .iCCD_start(start),

    .iFVAL(FVAL),
    .iDVAL(DVAL),
    .iDATA(DATA),

    .oDmem_wren(dmem_wren),
    .oDmem_addr(dmem_addr),
    .oDmem_data(dmem_data),

    .state(),
    .frame_val(),
    
    .oCCD_done(done)
);

always #5 clk = ~clk;

integer pxl_cnt;
integer clk_cnt;
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        clk_cnt = 0;
    else
        clk_cnt <= clk_cnt + 1;
end

assign DATA = pxl_cnt;
assign DVAL = FVAL;
assign pxlclk = clk;


initial begin
    clk = 0;
    rst_n = 0;
    enable = 0;
    start = 0;
    FVAL = 0;


    repeat(2) @ (negedge clk);
    rst_n = 1;
    repeat(3) @ (posedge clk);
    enable = 1;
    repeat(3) @ (posedge clk);
    start = 1;
    repeat (3) @ (posedge clk);
    start = 0;

    repeat(3) @ (posedge clk);

    FVAL = 1;
    repeat (2) @ (posedge clk);
    
    pxl_cnt = 0;
    $display("Starting pixels at clock count %d", clk_cnt);

    repeat(784) @ (posedge clk) pxl_cnt = pxl_cnt + 1;
    FVAL = 0;
    $display("Stopping pixels at clock count %d", clk_cnt);


end

integer wren_cnt;
always_ff @(posedge clk, negedge rst_n)
    if (~rst_n)
        wren_cnt = 0;
    else if (dmem_wren) begin
        wren_cnt = wren_cnt + 1;
        $display("Written to %h: %p", dmem_addr, dmem_data);
    end
    

initial begin
    #50000 $stop;
end

endmodule