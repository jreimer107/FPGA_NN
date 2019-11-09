module ALU (
    input [15:0]a,
    input [15:0]b,
    input [4:0]ctrl,
    output [15:0]out,
    output ovfl
);
    wire ovfl_temp;
    reg [15:0]out_temp;
	
    wire [15:0]out_addsub;
    wire [15:0]out_and;
    wire [15:0]out_or;
    wire [15:0]out_xor;
    wire [15:0]out_sll;
    wire [15:0]out_sra;
    wire [15:0]out_imml;
    wire [15:0]out_immh;

    assign out = out_temp;
    assign sub = (ctrl == 5'h1) ? 1'b1 : 1'b0;

    always@(*) begin
        case (ctrl)
            5'h0: out_temp = out_addsub;
			5'h1: out_temp = out_addsub;
            5'h2: out_temp = out_and;
            5'h3: out_temp = out_or;
            5'h4: out_temp = out_xor;
            5'h5: out_temp = out_sll;
            5'h6: out_temp = out_sra;
            5'h8: out_temp = out_imml;
            5'h9: out_temp = out_immh;
            default : out_temp = 16'b0;
        endcase
    end


    ADDSUB U_ADDSUB(
    .a(a),
    .b(b),
    .sub(sub),
    .sum(out_addsub),
    .ovfl(ovfl_temp)
    );

    assign out_and = a & b;
    assign out_or  = a | b;
    assign out_xor = a ^ b;
	
    SLL sll(.a(a), .shift(b[3:0]), .out(out_sll));
    SRA sra(.a(a), .shift(b[3:0]), .out(out_sra));
	
    assign out_imml = {a[15:8], b[7:0]};
    assign out_immh = {b[7:0], a[7:0]};
	
    assign ovfl = (ctrl == 4'h0 | ctrl == 4'h1) & ovfl_temp;
    
endmodule