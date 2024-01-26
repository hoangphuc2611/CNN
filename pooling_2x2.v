module pooling_2x2 #(parameter BIT_WIDTH = 32) (
    input clk,
    input en,
    input signed[BIT_WIDTH-1:0] in1, in2,
    output signed[BIT_WIDTH-1:0] maxOut
);

parameter SIZE = 2;

wire signed[BIT_WIDTH-1:0] out1;
wire signed[BIT_WIDTH-1:0] out2;

pooling_buffer #(BIT_WIDTH) PB (
    .clk(clk),
    .en(en),
    .in1(in1),
    .in2(in2),
    .out1(out1),
	 .out2(out2)
);

wire signed[BIT_WIDTH-1:0] maxR1, maxR2;

max #(.BIT_WIDTH(BIT_WIDTH)) M1 (
	.in1(out1[0]), .in2(out1[1]),
	.max(maxR1)
);

max #(.BIT_WIDTH(BIT_WIDTH)) M2 (
	.in1(out2[0]), .in2(out2[1]),
	.max(maxR2)
);

max #(.BIT_WIDTH(BIT_WIDTH)) M0 (
	.in1(maxR1), .in2(maxR2),
	.max(maxOut)
);


endmodule 