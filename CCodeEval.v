/* CCodeEval
* This module both stores the condition codes set by the previous instructions
* and evaluates the code requested by the current instruction.
* @input instr is the current instruction in full. Based on which instruction
* type it is, this module will either update its condition codes or use them to
* output a value which can be used for control functions. No instruction will
* ever write and read from the condition codes, so this is not a concern.
* @alu_out is the output of the ALU due to the current instructon.
* @alu_ovfl signifies if the current instruction caused overflow.
* @out is a 1 bit signal which is 1 when the requested condition matches the
*   current codes and 0 otherwise.
*/
module CCodeEval(C, NVZ, cond_true);
	input [2:0] C, NVZ;
	output cond_true;
	wire N, V, Z;
	assign {N,V,Z} = NVZ;

	localparam  ne = 3'b000;
	localparam  eq = 3'b001;
	localparam  gt = 3'b010;
	localparam  lt = 3'b011;
	localparam  ge = 3'b100;
	localparam  le = 3'b101;
	localparam  ov = 3'b110;
	localparam  un = 3'b111;

	//Evaluate condition
	always
		case (C)
			ne : cond_true = ~Z;
			eq : cond_true = Z;
			gt : cond_true = (~Z & ~N);
			lt : cond_true = N;
			ge : cond_true = (Z | (~N & ~Z));
			le : cond_true = (N | Z);
			ov : cond_true = V;
			un : cond_true = 1'b1;
			default: cond_true = 1'b0;
		endcase


	// assign cond_true = (C == ne && ~Z			    ||
	// 					C == eq && Z                ||
	// 					C == gt && (~Z & ~N)        ||
	// 					C == lt && N                ||
	// 					C == ge && (Z | (~N & ~Z))  ||
	// 					C == le && (N | Z)          ||
	// 					C == ov && V                ||
	// 					C == un)  ?
	// 						1'b1 : 1'b0;
endmodule
