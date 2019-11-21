module cpu (
    input clk,                   // Clock
    input rst_n,                 // Asynchronous reset active low
	input [15:0] dmem_data_from,    // load data from data BRAM
	input [15:0] bus_data_in,    // data from accelerator
    output [15:0] bus_data_out,  // data to accelerator
	output dmem_ren,          // enable BRAM for read
	output dmem_wren,          // write enable to BRAM
	output [15:0] dmem_addr, // read/write address to BRAM
	output [15:0] dmem_data_to  // store data to BRAM
);

    // ex
    wire [15:0] ex_reg1_data;
    wire [15:0] ex_reg2_data;
    wire [15:0] ex_imm;
    wire ex_regwrite;
    wire [3:0] ex_dest;
    wire [3:0] ex_src1;
    wire [3:0] ex_src2;
    wire ex_memtoreg;
    wire ex_bustoreg;
    wire ex_memread;
    wire ex_memwrite;
    wire ex_buswrite;
    wire [4:0] ex_opcode;
    wire ex_alusrc;
    wire [2:0] nvz;
	wire regwrite;

    // mem/wb
    wire mem_memread;
    wire mem_memwrite;
    wire mem_memtoreg;
    wire mem_bustoreg;
    wire [15:0] mem_alu_in;
    wire [15:0] mem_alu_src2;
	reg regwrite_prev_out;
    wire wb_en;
    wire [3:0] wb_dest;
    wire [15:0] wb_data;
    reg [3:0] wb_dest_prev_out;
    reg [15:0]wb_data_prev_out;

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // if/id stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    fetchdecode U_IFID(
	.iclk(clk),
	.irst_n(rst_n),
	.iWriteReg(wb_en),      // write reg data into reg file: from writeback stage
	.iWriteRegAddr(wb_dest),      // dest reg: from writeback stage
	.iWriteRegData(wb_data), // reg write data: from writeback stage
	.iMemtoReg(mem_memtoreg),      // write memory data to reg file: from writeback stage
	.iBustoReg(mem_bustoreg),      // bus data to reg file: from writeback stage 
	.iNVZ(nvz),                    // NVZ flag: from execute stage
	.oData1(ex_reg1_data),         // src reg1 data: to execute stage
	.oData2(ex_reg2_data),         // src reg2 data: to execute stage
	.oImm(ex_imm),                 // immediate value: to execute stage
	.oWriteReg(ex_regwrite),       // write reg data: to execute stage
	.oWriteRegAddr(ex_dest),       // dest reg: to execute stage
	.oMemtoReg(ex_memtoreg),       // select memory data and write to dest reg: to execute stage
	.oBustoReg(ex_bustoreg),       // select accelerator bus data and write to dest reg: to execute stage
	.oMemRead(ex_memread),         // read enable for BRAM on a load: to execute stage
	.oMemWrite(ex_memwrite),       // write enable for BRAM on a store: to execute stage
	.oBusWrite(ex_buswrite),       // slect bus data to write to reg file: to execute stage
	.oOpcode(ex_opcode),           // opcode: to execute stage
	.oALUSrc(ex_alusrc),           // select immediate value for ALU: to execute stage
	.oSr1(ex_src1),                // src1 reg: to execute stage
	.oSr2(ex_src2),		           // src2 reg: to execute stage
	.iStall(mem_memread)		   // stall on data load
    );

    // ADD Instruction BROM here

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // ex stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    execute U_EX(
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low
	.ex_regwrite_in(ex_regwrite),
	.ex_memtoreg_in(ex_memtoreg),
	.ex_bustoreg_in(ex_bustoreg),
	.ex_memread_in(ex_memread),
	.ex_memwrite_in(ex_memwrite),
	.ex_aluop(ex_opcode),
	.ex_alusrc(ex_alusrc),
	.ex_reg_1(ex_reg1_data),
	.ex_reg_2(ex_reg2_data),
	.ex_imm(ex_imm),
	.ex_regrdaddr1_in(ex_src1),
	.ex_regrdaddr2_in(ex_src2),
	.ex_regwraddr_in(ex_dest),
	.mem_regwrite_in(regwrite),
	.mem_memread_in(mem_memread),
	.mem_regwraddr_in(wb_dest),
	.mem_regwrdata_in(wb_data),
	.mem_regwrite_prev_in(regwrite_prev_out),
    .mem_regwraddr_prev_in(wb_dest),
    .mem_regwrdata_prev_in(wb_data),
	.ex_flag_out(nvz),
	.ex_regwrite_out(wb_en),
	.ex_memtoreg_out(mem_memtoreg),
	.ex_bustoreg_out(mem_bustoreg),
	.ex_memread_out(mem_memread),
	.ex_memwrite_out(mem_memwrite),
	.ex_alu_out(mem_alu_in),
	.ex_alu_src2_out(mem_alu_src2),
	.ex_regwraddr_out(wb_dest)
    );

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // mem/wb stage
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    assign dmem_data_to = mem_alu_src2;
	assign dmem_addr = mem_alu_in;
    assign dmem_ren = mem_memread;
    assign dmem_wren = mem_memwrite;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			regwrite_prev_out <= 1'b0;
			wb_dest_prev_out <= 4'b0;
			wb_data_prev_out <= 16'b0;
		end
		else begin
			regwrite_prev_out <= regwrite;
			wb_dest_prev_out <= wb_dest;
			wb_data_prev_out <= wb_data;
		end
	end

	assign regwrite = wb_en | mem_memtoreg | mem_bustoreg;
    
    assign wb_data = (mem_bustoreg == 1) ? bus_data_in : ((mem_memtoreg == 1) ? dmem_data_from : ((wb_en == 1) ? mem_alu_in : 16'b0));

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    //
    // accelerator interface
    //
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	assign bus_data_out = 0;


endmodule
