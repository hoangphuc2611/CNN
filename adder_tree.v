module adder_tree #(parameter BIT_WIDTH = 32) (
    input signed [BIT_WIDTH*25 - 1 : 0] in,
	input signed [7:0] bias,
	output signed [BIT_WIDTH - 1 : 0] out
);
    wire signed [BIT_WIDTH - 1 : 0] product [24:0];
    wire signed [BIT_WIDTH - 1 : 0] sum [22:0];
	
	genvar x;
	
	generate
		for (x = 0; x < 25; x = x + 1) begin : product_count
			assign product[x] = in[BIT_WIDTH*(x + 1) - 1 : BIT_WIDTH*x];
		end
		for (x = 0; x < 12; x = x + 1) begin : adder_tree_layer1_C1
			assign sum[x] = product[x * 2] + product[x * 2 + 1];
		end
		for (x = 0; x < 6; x = x + 1) begin : adder_tree_layer2_C1
			assign sum[x + 12] = sum[x * 2] + sum[x * 2 + 1];
		end
		for (x = 0; x < 3; x = x + 1) begin : adder_tree_layer3_C1
			assign sum[x + 18] = sum[x * 2 + 12] + sum[x * 2 + 13];
		end
		assign sum[21] = sum[18] + sum[19];
		assign sum[22] = sum[20] + product[24];
      assign out = sum[21] + sum[22] + bias;
	endgenerate
	
endmodule
