module row_buffer_4 #(parameter LENGTH = 32, BIT_WIDTH = 8)(
	input [BIT_WIDTH-1:0] in,
	input clk, en,
	output [BIT_WIDTH-1:0] out0, out1, out2, out3
);	
	row_buffer #(.LENGTH(LENGTH), .BIT_WIDTH(BIT_WIDTH)) rb0 (
		.in(in), .clk(clk), .en(en), .out(out0)
	);
	row_buffer #(.LENGTH(LENGTH), .BIT_WIDTH(BIT_WIDTH)) rb1 (
		.in(out0), .clk(clk), .en(en), .out(out1)
	);
	row_buffer #(.LENGTH(LENGTH), .BIT_WIDTH(BIT_WIDTH)) rb2 (
		.in(out1), .clk(clk), .en(en), .out(out2)
	);
	row_buffer #(.LENGTH(LENGTH), .BIT_WIDTH(BIT_WIDTH)) rb3 (
		.in(out2), .clk(clk), .en(en), .out(out3)
	);
endmodule
