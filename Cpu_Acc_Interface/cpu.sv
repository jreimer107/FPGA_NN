module cpu (
	input clk,                   // Clock
	input rst_n,                 // Asynchronous reset active low

	// DMEM interface
	input [15:0] dmem_data_from,    // load data from data BRAM
	output dmem_ren,          // enable BRAM for read
	output dmem_wren,          // write enable to BRAM
	output [10:0] dmem_addr, // read/write address to BRAM
	output [15:0] dmem_data_to,  // store data to BRAM

	// Accelerator interface
	input  accel_done,
	// output accel_start,
	output accel_en,
	output bus_wr,
	// output [2:0] bus_accregaddr,
	output [15:0] bus_data,

	//IPU interface
	input ccd_done,
	output ccd_en,

	// Testing/Demo signals
	input pc_advance,
	input [3:0] reg_index,
	output reg halt,
	output [23:0] instr_out,
	output [15:0] pc_out,
	output [15:0] reg_out
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

	//Forwarding
	wire [1:0] forward;

	/// mem/wb ///
	wire mem_memread;
	wire mem_memwrite;
	wire mem_buswrite;
	wire mem_halt;
	wire [2:0] bus_addr;

	wire [15:0] mem_alu_in;
	wire [15:0] mem_alu_src2;

	// Writeback sources
	wire mem_alutoreg;
	wire mem_memtoreg;
	wire mem_bustoreg;

	// Writeback signals
	wire wb_en;
	wire [3:0] wb_dest;
	wire [3:0] dest_reg;
	reg [15:0] wb_data;

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// if/id stage
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	fetchdecode U_IFID(
	.clk(clk),
	.rst_n(rst_n),
	.iWriteBack_en(wb_en),     	   // write reg data into reg file: from writeback stage
	.iWriteBackAddr(dest_reg),     // dest reg: from writeback stage
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
	.oBusWrite(ex_buswrite),       // write enable for bus data
	.iHalt(halt),		   		   // Halt
	.iCCD_done(ccd_done),
	.oCCD_en(ccd_en),
	.iACC_done(accel_done),
	//.oACC_en(accel_en),
	//.oACC_start(bus_accel_start),
	.PC(pc_out),
	.oReg_Out(reg_out),
	.iRegIndex(reg_index),
	.iPC_advance(pc_advance),
	.oInstr_out(instr_out)
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
		.iBusWrite(ex_buswrite),
		.iAluOp(ex_opcode),
		.iAluUseImm(ex_AluUseImm),
		.iData1(ex_reg1_data),
		.iData2(ex_reg2_data),
		.iImm(ex_imm),
		.iSr1(ex_src1),
		.iSr2(ex_src2),
		.iWriteBackData(wb_data),
		.iForward(forward),
		.iFlush(halt),
		.oNVZ(nvz),
		.oAlutoReg(mem_alutoreg),
		.oMemtoReg(mem_memtoreg),
		.oBustoReg(mem_bustoreg),
		.oMemRead(mem_memread),
		.oMemWrite(mem_memwrite),
		.oAluOut(mem_alu_in),
		.oData2(mem_alu_src2),
		.oDest(wb_dest),
		.oBusWrite(mem_buswrite),
		.oBusAddr(bus_addr),
		.oHalt(mem_halt)
	);

	ForwardingUnit U_FWD(
		.ex_sr1(ex_src1),
		.ex_sr2(ex_src2),
		.wb_dest(dest_reg),
		.wb_en(wb_en),
		.oForward(forward)
	);

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// mem/wb stage
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	reg mem_memtoreg_delay;
	reg [3:0] wb_dest_delay;

	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			mem_memtoreg_delay <= 1'b0;
			wb_dest_delay <= 4'b0;
		end
		else begin
			mem_memtoreg_delay <= mem_memtoreg;
			wb_dest_delay <= wb_dest;
		end
	end

	assign dest_reg = (mem_memtoreg_delay == 1'b1) ? wb_dest_delay : wb_dest; 

	// Dmemory interface
	assign dmem_data_to = mem_alu_src2;
	assign dmem_addr = mem_alu_in[10:0];
	assign dmem_ren = (halt == 1'b1) ? 1'b0 : mem_memread;
	assign dmem_wren = (halt == 1'b1) ? 1'b0 : mem_memwrite;

	// Writeback control
	assign wb_en = (halt == 1'b1) ? 1'b0 : (mem_alutoreg | mem_memtoreg_delay | mem_bustoreg);
	assign wb_data = mem_memtoreg_delay ? dmem_data_from :
	// 				 mem_bustoreg ? bus_data :
	                 mem_alutoreg ? mem_alu_in :
					 16'h0;
	
	// HALT regsiter
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			halt <= 1'b0;
		else
			halt <= (mem_halt == 1'b1) ? 1'b1 : halt;

	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	//
	// accelerator interface
	//
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	assign bus_data = bus_wr ? mem_alu_src2 : 16'h0;
	assign bus_wr = (halt == 1'b1) ? 1'b0 : mem_buswrite;
	// assign bus_accregaddr = mem_bustoreg ? bus_addr :
	//						mem_buswrite ? bus_addr : 3'hz;  


	assign accel_en = ~ccd_done;

endmodule
