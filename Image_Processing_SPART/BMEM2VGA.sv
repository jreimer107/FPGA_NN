module BMEM2VGA(
    input iCLK, iRST,

    input   [15:0]  iDATA,
    input           iDONE,

    output          oREN,
    output  [10:0]  oADDR,

    output  [11:0]  ovgaDATA,
    output          ovgaDVAL
);
 reg [783:0][15:0] cropdown;
 reg [10:0] sample_cnt;
 reg [19:0] TARG_cnt;
 reg iDVAL;


 assign oREN = iDONE && sample_cnt < 784;
 assign oADDR = sample_cnt;

 reg old_oREN;
 always_ff @(posedge iCLK, negedge iRST)
   if(!iRST)
     old_oREN <= 0;
   else
     old_oREN <= oREN;

 reg old_old_oREN;
 always_ff @(posedge iCLK, negedge iRST)
   if(!iRST)
     old_old_oREN <= 0;
   else
     old_old_oREN <= old_oREN;

 always_ff @(posedge iCLK, negedge iRST)
   if(!iRST)
     iDVAL <= 0;
   else if(oREN && old_oREN && old_old_oREN)
     iDVAL <= 1;

 always_ff @(posedge iCLK, negedge iRST)
   if(!iRST)
     cropdown <= '{default:0};
   else if(TARG_cnt == 307200)
     cropdown <= '{default:0};
   else if(iDVAL && sample_cnt < 784)
     cropdown <= {iDATA, cropdown[783:1]};

 always_ff @(posedge iCLK, negedge iRST)
   if(!iRST)
     sample_cnt <= '{default:0};
   else if(TARG_cnt == 307200)
     sample_cnt <= '{default:0};
   else if(oREN && old_oREN && old_old_oREN)
     sample_cnt <= sample_cnt + 1;

 // assign oSC = {cropdown[783],cropdown[0]};

 reg [6:0] clk_cnt;
 always @(posedge iCLK, negedge iRST)
   if(!iRST)
     clk_cnt <= 0;
   else if(sample_cnt == 0)
     clk_cnt <= 0;
   else if(sample_cnt >= 784)
     clk_cnt <= clk_cnt + 1;

 wire modDVAL;

 always_ff @(posedge iCLK, negedge iRST)
   if(!iRST)
     TARG_cnt <= 0;
   else if(sample_cnt == 0)
     TARG_cnt <= 0;
   else if(modDVAL) begin
     TARG_cnt <= TARG_cnt + 1;
   end

 assign modDVAL = &clk_cnt && TARG_cnt <= 307200;

 wire [9:0] oX, oY;
 assign oX = TARG_cnt % 640;
 assign oY = TARG_cnt / 640;

 assign ovgaDVAL = modDVAL;
assign ovgaDATA = {cropdown[(oX % 28)+(28*(oY%28))][7:0], 4'h0};//(oX < 28 && oY < 28) ? cropdown[(oX + 28*oY)] : 0;
// assign ovgaDATA = (oX < 28 && oY < 28) ? cropdown[(oX + 28*oY)] : 0;


endmodule
