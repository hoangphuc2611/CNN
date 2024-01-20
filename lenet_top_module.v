module lenet_top_module #(parameter IMAGE_SIZE = 32, IN_WIDTH = 8, OUT_WIDTH = 32) (
	input clk, rst,
	input signed [IN_WIDTH - 1 : 0] input_pixel,
	output [3:0] out,
	output [OUT_WIDTH - 1 : 0] out_C10, out_C11, out_C12, out_C13, out_C14, out_C15
);
	parameter	C1_SIZE = 28,
					C3_SIZE = 10;
					
	parameter	C1_MAPS = 6,
					C3_MAPS = 16,
					C5_MAPS = 120;
					
	parameter	FILTER_SIZE = 25; // 5x5 + 1 for bias
	
	// CONVOLUTIONAL LAYER 1
	
	reg [IN_WIDTH-1:0] matrix_C1 [4:0][4:0];
	
	wire signed [(IN_WIDTH * (FILTER_SIZE + 1)* C1_MAPS) - 1 : 0] filter_C1; //Plus 1 for bias
	wire signed [IN_WIDTH - 1 : 0] out_rb_C1 [3:0];
	wire signed [OUT_WIDTH - 1 : 0] out_C1 [C1_MAPS - 1 : 0];
	//output signed [OUT_WIDTH - 1 : 0] out_C10;

	
	integer i;
	genvar x, y, z;
	
	// Memory for storing weights and bias
	weights_bias #(.SIZE(FILTER_SIZE + 1), .NUM(C1_MAPS), .BIT_WIDTH(IN_WIDTH), .FILE("blank.txt")) wb_C1 (
		.clk(clk), .read(1'b1), .out(filter_C1)
	);
	
	// Buffer block for matrix dot product of C1 layer
	row_buffer_4 #(.LENGTH(IMAGE_SIZE), .BIT_WIDTH(IN_WIDTH)) rb (
		.in(input_pixel), .clk(clk), .en(1'b1),
		.out0(out_rb_C1[0]), .out1(out_rb_C1[1]), .out2(out_rb_C1[2]), .out3(out_rb_C1[3])
	);
	
	always @(posedge clk) begin
		//if (en)	begin
			for(i = 4; i > 0; i = i - 1) begin
				matrix_C1[0][i] <= matrix_C1[0][i-1];
				matrix_C1[1][i] <= matrix_C1[1][i-1];
				matrix_C1[2][i] <= matrix_C1[2][i-1];
				matrix_C1[3][i] <= matrix_C1[3][i-1];
				matrix_C1[4][i] <= matrix_C1[4][i-1];
			end
			matrix_C1[0][0] <= input_pixel;
			matrix_C1[1][0] <= out_rb_C1[0];
			matrix_C1[2][0] <= out_rb_C1[1];
			matrix_C1[3][0] <= out_rb_C1[2];
			matrix_C1[4][0] <= out_rb_C1[3];
		//end
	end
	
	// Multiplication
	wire signed [OUT_WIDTH - 1 : 0] product [(FILTER_SIZE * C1_MAPS) - 1 : 0];
	
	generate
		for (z = 0; z < C1_MAPS; z = z + 1) begin : filter_count_mul_C1
			for (x = 0; x < 5; x = x + 1) begin : row_count_C1
				for (y = 0; y < 5; y = y + 1) begin : column_count_C1
					assign product[FILTER_SIZE*z + 5*x + y] = matrix_C1[x][y] * filter_C1[8*(FILTER_SIZE*z + 5*x + y + 1) - 1 : 8*(25*z + 5*x + y)];
				end
			end
		end
	endgenerate
	// Adder tree
	wire signed [OUT_WIDTH - 1 : 0] sum [(FILTER_SIZE - 1)*C1_MAPS - 1:0];
	generate
		for (y = 0; y < C1_MAPS; y = y + 1) begin : filter_count_add_C1
			for (x = 0; x < 12; x = x + 1) begin : adder_tree_layer1_C1
				assign sum[(FILTER_SIZE - 1)*y + x] = product[FILTER_SIZE*y + x*2] + product[FILTER_SIZE*y + x*2 + 1];
			end
			for (x = 0; x < 6; x = x + 1) begin : adder_tree_layer2_C1
				assign sum[(FILTER_SIZE - 1)*y + x + 12] = sum[(FILTER_SIZE - 1)*y + x*2] + sum[(FILTER_SIZE - 1)*y + x*2 + 1];
			end
			for (x = 0; x < 3; x = x + 1) begin : adder_tree_layer3_C1
				assign sum[(FILTER_SIZE - 1)*y + x + 18] = sum[(FILTER_SIZE - 1)*y + x*2 + 12] + sum[(FILTER_SIZE - 1)*y + x*2 + 13];
			end
			assign sum[(FILTER_SIZE - 1)*y + 21] = sum[(FILTER_SIZE - 1)*y + 18] + sum[(FILTER_SIZE - 1)*y + 19];
			assign sum[(FILTER_SIZE - 1)*y + 22] = sum[(FILTER_SIZE - 1)*y + 20] + product[FILTER_SIZE*y + 24];
			assign sum[(FILTER_SIZE - 1)*y + 23] = sum[(FILTER_SIZE - 1)*y + 21] + sum[(FILTER_SIZE - 1)*y + 22] + filter_C1[FILTER_SIZE*(y + 1)*IN_WIDTH + IN_WIDTH : FILTER_SIZE*(y + 1)*IN_WIDTH];
			relu #(.BIT_WIDTH(OUT_WIDTH)) relu (.in(sum[(FILTER_SIZE - 1)*y + 23]), .out(out_C1[y]));
		end
	endgenerate
	assign out_C10 = out_C1[0];
	assign out_C11 = out_C1[1];
	assign out_C12 = out_C1[2];
	assign out_C13 = out_C1[3];
	assign out_C14 = out_C1[4];
	assign out_C15 = out_C1[5];
endmodule

