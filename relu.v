module relu #(parameter BIT_WIDTH = 32)(
    input signed [BIT_WIDTH - 1 : 0] in,
    output signed [BIT_WIDTH - 1 : 0] out
);
    assign out = (in[BIT_WIDTH - 1]) ? 32'b0 : in;
endmodule