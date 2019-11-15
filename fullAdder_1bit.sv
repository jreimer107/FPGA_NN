module fullAdder_1bit (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    assign cout = (a & b) | (a & cin) | (b & cin);
    assign sum = a ^ b ^ cin;

endmodule