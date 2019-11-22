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

	/// ex ///
	wire [15:0] ex_reg1_data;
	wire [15:0] ex_reg2_data;
	wire [15:0] ex_imm;
	wire [3:0] ex_dest;
	wire [3:0] ex_src1;
	wire [3:0] ex_src2;

	// Writeback sources
	wire ex_alutoreg;
	wire ex_memtoreg;
	wire ex_bustoreg;

	wire ex_memread;
	wire ex_memwrite;
	wire ex_buswrite;
	wire [4:0] ex_opcode;
	wire ex_AluUseImm;
	wire [2:0] nvz;
	wire regwrite;

	//Forwarding
	wire [1:0] forward;

	/// mem/wb ///
	wire mem_memread;
	wire mem_memwrite;

	wire [15:0] mem_alu_in;
	wire [15:0] mem_alu_src2;
	reg regwrite_prev_out;
	reg [3:0] wb_dest_prev_out;
	reg [15:0]wb_data_prev_out;

	// Writeback sources
	wire mem_alutoreg;
	wire mem_memtoreg;
	wire mem_bustoreg;

	// Writeback signals
	wire wb_en;
	wire [3:0] wb_dest;
	wire [15:0] wb_data;

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// if/id stage
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	fetchdecode U_IFID(
	.clk(clk),
	.rst_n(rst_n),
	.iWriteBack_en(wb_en),     	   // write reg data into reg file: from writeback stage
	.iWriteBackAddr(wb_dest),      // dest reg: from writeback stage
	.iWriteBackData(wb_data), 	   // reg write data: from writeback stage
	.iNVZ(nvz),                    // NVZ flag: from execute stage
	.oOpcode(ex_opcode),           // opcode: to execute stage
	.oSr1(ex_src1),                // src1 reg: to execute stage
	.oSr2(ex_src2),		           // src2 reg: to execute stage
	.oImm(ex_imm),                 // immediate value: to execute stage
	.oData1(ex_reg1_data),         // src reg1 data: to execute stage
	.oData2(ex_reg2_data),         // src reg2 data: to execute stage
	.oAlutoReg(ex_alutoreg),       // write reg data: to execute stage
	.oMemtoReg(ex_memtoreg),       // select memory data and write to dest reg: to execute stage
	.oBustoReg(ex_bustoreg),       // select accelerator bus data and write to dest reg: to execute stage
	.oWriteBackAddr(ex_dest),      // dest reg: to execute stage
	.oALUSrc(ex_AluUseImm),        // select immediate value for ALU: to execute stage
	.oMemRead(ex_memread),         // read enable for BRAM on a load: to execute stage
	.oMemWrite(ex_memwrite),       // write enable for BRAM on a store: to execute stage
	.oBusWrite(ex_buswrite),       // slect bus data to write to reg file: to execute stage
	.iStall(mem_memread)		   // stall on data load
	);

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// ex stage
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	execute U_EX(
		.clk(clk),
		.rst_n(rst_n),
		.iAlutoReg(ex_alutoreg), 		// store alu result in register
		.iMemtoReg(ex_memtoreg), 		// store memory data in register
		.iBustoReg(ex_bustoreg),		// store bus data in regiser
		.iDest(ex_dest),				// destination upon writeback
		.iMemRead(ex_memread),
		.iMemWrite(ex_memwrite),
		.iAluOp(ex_opcode),
		.iAluUseImm(ex_AluUseImm),
		.iData1(ex_reg1_data),
		.iData2(ex_reg2_data),
		.iImm(ex_imm),
		.iSr1(ex_src1),
		.iSr2(ex_src2),
		.iWriteBackData(iWriteBackData),
		.iForward(forward),
		.oNVZ(nvz),
		.oAlutoReg(mem_alutoreg),
		.oMemtoReg(mem_memtoreg),
		.oBustoReg(mem_bustoreg),
		.oMemRead(mem_memread),
		.oMemWrite(mem_memwrite),
		.oAluOut(mem_alu_in),
		.oData2(mem_alu_src2),
		.oDest(wb_dest)
	);

	ForwardingUnit U_FWD(
		.ex_sr1(ex_sr1),
		.ex_sr2(ex_sr2),
		.wb_dest(wb_dest),
		.wb_en(wb_en),
		.Forward(forward)
	);

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// mem/wb stage
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	// Dmemory interface
	assign dmem_data_to = mem_alu_src2;
	assign dmem_addr = mem_alu_in;
	assign dmem_ren = mem_memread;
	assign dmem_wren = mem_memwrite;

	// Writeback control
	assign wb_en = mem_alutoreg | mem_memtoreg | mem_bustoreg;
	always_comb begin
		if (mem_alutoreg)
			wb_data = mem_alu_in;
		if (mem_bustoreg)
			wb_data = bus_data_in;
		else if  (mem_memtoreg)
			wb_data = dmem_data_from;
		else
			wb_data = 16'h0;
	end

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// accelerator interface
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	assign bus_data_out = 0;


endmodule
