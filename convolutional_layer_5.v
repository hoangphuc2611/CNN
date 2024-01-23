module convolutional_layer_5 #(parameter IN_WIDTH = 32, OUT_WIDTH = 32, MAPS = 120) (
	input signed [IN_WIDTH * 16 - 1 : 0] in,
	input clk, en, read,
	output signed [OUT_WIDTH * MAPS - 1 : 0] out
);
	genvar x, y;

	wire signed [(16 * 25 + 1) * MAPS * 8 - 1 : 0] filter ;
	
	wire signed [IN_WIDTH*5 - 1 : 0]  matrix [15:0][4:0];

	wire signed [OUT_WIDTH*25 - 1 : 0] out_mul [MAPS - 1 : 0][15:0];

	wire signed [OUT_WIDTH - 1 : 0] out_add [MAPS - 1 : 0][29:0];
	
	wire signed [OUT_WIDTH - 1 : 0] out_maps [MAPS - 1 : 0];

	weights_bias #(.SIZE(25 * 16 + 1), .NUM(MAPS), .FILE("c5_weights_bias.txt")) wb (
		.clk(clk), .read(read), .out(filter)
	);

	generate
		for (x = 0; x < 16; x = x + 1) begin : input_maps_count
		
			matrix_buffer #(.SIZE(5), .BIT_WIDTH(32)) rb (
				.in(in[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x]), .clk(clk), .en(en),
				.out0(matrix[x][0]), .out1(matrix[x][1]), .out2(matrix[x][2]), .out3(matrix[x][3]), .out4(matrix[x][4])
			);
		end
		
		for (x = 0; x < MAPS; x = x + 1) begin : output_maps_count
		
			for (y = 0; y < 16; y = y + 1) begin : input_calculation_count
			
				multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul (
					.in0(matrix[y][0]), .in1(matrix[y][1]), .in2(matrix[y][2]), .in3(matrix[y][3]), .in4(matrix[y][4]),
					.filter(filter[3208*x + 200*y + 199 : 3208*x + 200*y]), .out(out_mul[x][y])
				);
				
				adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add (
					.in(out_mul[x][y]), .bias(8'b0), .out(out_add[x][y])
				);
			end
			
			for (y = 0; y < 8; y = y + 1) begin : adder_tree_layer1
				assign out_add[x][y + 16] = out_add[x][2*y] + out_add[x][2*y + 1];
			end
			
			for (y = 0; y < 4; y = y+1) begin : adder_tree_layer2
				assign out_add[x][y + 24] = out_add[x][2*y + 16] + out_add[x][2*y + 17];
			end
			
			for (y = 0; y < 2; y = y+1) begin : adder_tree_layer3
				assign out_add[x][y + 28] = out_add[x][2*y + 24] + out_add[x][2*y + 25];
			end
			
			assign out_maps[x] = out_add[x][28] + out_add[x][29] + filter[3208*x + 3207 : 3208*x + 3200];
			
			relu #(.BIT_WIDTH(OUT_WIDTH)) activation (
				.in(out_maps[x]), .out(out[OUT_WIDTH*(x + 1) - 1 : OUT_WIDTH*x])
			);
		end
	endgenerate
	
endmodule
