/*
 * This is the testbench from 552 with minor modifications to fit our ISA.
 * Also it's cleaned up, it had spaces and tabs everywhere and looked like trash.
*/
`timescale 1ps/1ps
module cpu_tb();


wire [15:0] PC;
wire [23:0] Inst;           /* This should be the 15 bits of the FF that
								stores instructions fetched from instruction memory
							*/
wire        RegWrite;       /* Whether register file is being written to */
wire [3:0]  WriteRegister;  /* What register is written */
wire [15:0] WriteData;      /* Data */
wire        MemWrite;       /* Similar as above but for memory */
wire        MemRead;
wire [15:0] MemAddress;
wire [15:0] MemDataIn;	/* Read from Memory */
wire [15:0] MemDataOut;	/* Written to Memory */

wire        Halt;         /* Halt executed and in Memory or writeback stage */
	
integer     inst_count;
integer     cycle_count;

integer     trace_file;
integer     sim_log_file;


reg clk; /* Clock input */
reg rst_n; /* (Active low) Reset input */

wire mem_data_en = MemRead | MemWrite;

reg pc_advance;
reg [3:0] reg_index;
wire [15:0] reg_out;
cpu_dmem_wrapper DUT (
	.clk(clk),
	.rst_n(rst_n),
	.pc_advance(pc_advance),
	.pc_out(PC),
	.reg_index(reg_index),
	.reg_out(reg_out),
	.instr_out(Inst),
	.halt(Halt)
);

// cpu DUT(.clk(clk), .rst_n(rst_n), .mem_data_in(MemDataOut), .bus_data_in(16'h0),
// 	.bus_data_out(), .mem_data_en(mem_data_en), .mem_data_wr(MemWrite),
// 	.mem_data_addr(MemAddress),  .mem_data_out(MemDataIn)
// ); /* Instantiate your processor */


/* Setup */
initial begin
	$display("Hello world...simulation starting");
	$display("See verilogsim.plog and verilogsim.ptrace for output");
	inst_count = 0;

	trace_file = $fopen("verilogsim.ptrace");
	sim_log_file = $fopen("verilogsim.plog");
	
end


/* Clock and Reset */
// Clock period is 100 time units, and reset length
// to 201 time units (two rising edges of clock).

initial begin
	$dumpvars;
	cycle_count = 0;
	rst_n = 0; /* Intial reset state */
	clk = 1;
	reg_index = 4'h1;
	pc_advance = 1'b0;
	#201 rst_n = 1; // delay until slightly after two clock periods
	repeat(12) begin
		@(posedge clk) pc_advance = 1'b1;
		@( posedge clk) pc_advance = 1'b0;
		repeat(3) @( posedge clk);
	end
end

always #50 begin   // delay 1/2 clock period each time thru loop
	clk = ~clk;
	//if (~clk) $stop();
	//if((DUT.IF.Imem.miss_detected !== 0) && ~clk) begin
	//		$display("MISS DETECTED:%x", DUT.IF.Imem.miss_detected);
	//		$stop;
	//end
	//if ((Inst == 16'hb580) && ~clk) $stop;
	//if (PC >= 16'h001c && ~clk) $stop;

end

always @(posedge clk) begin
	cycle_count = cycle_count + 1;
	if (cycle_count > 200) begin
		$display("hmm....more than 100000 cycles of simulation...error?\n");
		$stop;
	end
end




/* Stats */
always @ (posedge clk) begin
	if (rst_n) begin
		if (Halt || RegWrite || MemWrite) begin
			inst_count = inst_count + 1;
		end

		$fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %6x R: %d %3d %4x M: %d %d ADDR:%4x DATAIN:%4x DATAOUT:%4x",
				cycle_count,
				PC,
				Inst,
				RegWrite,
				WriteRegister,
				WriteData,
				MemRead,
				MemWrite,
				MemAddress,
				MemDataIn,
				MemDataOut,
		);

		if (RegWrite) begin
			$fdisplay(trace_file,"Cycle: %d REG: %d VALUE: 0x%04x",
				cycle_count,
				WriteRegister,
				WriteData );
		end
		if (MemRead) begin
			$fdisplay(trace_file,"Cycle: %d LOAD: ADDR: 0x%04x VALUE: 0x%04x",
					  cycle_count, MemAddress, MemDataOut );
		end

		if (MemWrite) begin
			$fdisplay(trace_file,"Cycle: %d STORE: ADDR: 0x%04x VALUE: 0x%04x",
					  cycle_count, MemAddress, MemDataIn  );
		end
		if (Halt) begin
			$fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
			$fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", cycle_count);
			$fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);


			$fclose(trace_file);
			$fclose(sim_log_file);
			
			#5;
			$finish;
		end 
	end
end


/* Assign internal signals to top level wires
	The internal module names and signal names will vary depending
	on your naming convention and your design */

// Edit the example below. You must change the signal
// names on the right hand side

// assign PC = DUT.CPU.U_IFID.PC; //You won't need this because it's part of the main cpu interface

// assign Halt = 0;
// assign Halt = DUT.memory0.halt; //You won't need this because it's part of the main cpu interface
// Is processor halted (1 bit signal)

// assign Inst = DUT.CPU.U_IFID.instr;
//Instruction fetched in the current cycle

assign RegWrite = DUT.CPU.wb_en;
// Is register file being written to in this cycle, one bit signal (1 means yes, 0 means no)

assign WriteRegister = DUT.CPU.wb_dest;
// If above is true, this should hold the name of the register being written to. (4 bit signal)

assign WriteData = DUT.CPU.wb_data;
// If above is true, this should hold the Data being written to the register. (16 bits)

assign MemRead =  DUT.dmem_ren;
// Is memory being read from, in this cycle. one bit signal (1 means yes, 0 means no)

assign MemWrite = DUT.CPU.dmem_wren;
// Is memory being written to, in this cycle (1 bit signal)

assign MemAddress = DUT.data_addr;
// If there's a memory access this cycle, this should hold the address to access memory with (for both reads and writes to memory, 16 bits)

assign MemDataIn = DUT.data_to_mem;
// If there's a memory write in this cycle, this is the Data being written to memory (16 bits)

assign MemDataOut = DUT.data_to_cpu;
// If there's a memory read in this cycle, this is the data being read out of memory (16 bits)


/* Add anything else you want here */

endmodule
