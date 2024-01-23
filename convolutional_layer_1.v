module convolutional_layer_1 #(parameter IN_WIDTH = 8, OUT_WIDTH = 32, MAPS = 6) (
	input signed [IN_WIDTH - 1 : 0] in,
	input clk, en, read,
	output signed [OUT_WIDTH*MAPS - 1 : 0] out
);				
	genvar x, y;

	wire signed [26 * MAPS * 8 - 1 : 0] filter;
	
	wire signed [IN_WIDTH*5 - 1 : 0] matrix [4:0];

	wire signed [OUT_WIDTH*25 - 1 : 0] out_mul [MAPS - 1 : 0];

	wire signed [OUT_WIDTH - 1 : 0] out_add [MAPS - 1 : 0];

	weights_bias #(.SIZE(26), .NUM(MAPS), .FILE("c1_weights_bias.txt")) wb (
		.clk(clk), .read(read), .out(filter)
	);

	matrix_buffer #(.BIT_WIDTH(IN_WIDTH), .SIZE(OUT_WIDTH)) mb (
		.in(in), .clk(clk), .en(1'b1),
		.out0(matrix[0]), .out1(matrix[1]), .out2(matrix[2]), .out3(matrix[3]), .out4(matrix[4])
	);

	generate
		for (x = 0; x < MAPS; x = x + 1) begin : maps_count
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul (
				.in0(matrix[0]), .in1(matrix[1]), .in2(matrix[2]), .in3(matrix[3]), .in4(matrix[4]),
				.filter(filter[208*(x + 1) - 9 : 208*x]), .out(out_mul[x])
			);
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add (
				.in(out_mul[x]), .bias(filter[208*(x + 1) - 1 : 208*(x + 1) - 8]), .out(out_add[x])
			);
			relu #(.BIT_WIDTH(OUT_WIDTH)) activation (
				.in(out_add[x]), .out(out[OUT_WIDTH*(x + 1) - 1 : OUT_WIDTH*x])
			);
		end
	endgenerate
endmodule
