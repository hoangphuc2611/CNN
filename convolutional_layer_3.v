module convolutional_layer_3 #(parameter IN_WIDTH = 8, OUT_WIDTH = 8, MAPS = 16) (
	input signed [IN_WIDTH*6 - 1 : 0] in,
	input clk, en, read,
	output signed [OUT_WIDTH*MAPS - 1 : 0] out
);				
	genvar x, y;

	wire signed [(25 * 3 + 1) * 6 * 8 - 1 : 0] filter3;

   wire signed [(25 * 4 + 1) * 9 * 8 - 1 : 0] filter4;

   wire signed [(25 * 6 + 1) * 1 * 8 - 1 : 0] filter6;
	
	wire signed [IN_WIDTH*5 - 1 : 0] matrix [5:0][4:0];

	wire signed [OUT_WIDTH*25 - 1 : 0] out_mul3 [5:0][2:0];
   wire signed [OUT_WIDTH*25 - 1 : 0] out_mul4 [8:0][3:0];
   wire signed [OUT_WIDTH*25 - 1 : 0] out_mul6      [5:0];

	wire signed [OUT_WIDTH - 1 : 0] out_add3 [5:0][2:0];
   wire signed [OUT_WIDTH - 1 : 0] out_add4 [8:0][3:0];
   wire signed [OUT_WIDTH - 1 : 0] out_add6      [5:0];

   wire signed [OUT_WIDTH - 1 : 0] out_maps [15:0];

	weights_bias #(.SIZE(25 * 3 + 1), .NUM(6), .FILE("c3_weights_bias_x3.txt")) wb_3 (
		.clk(clk), .read(read), .out(filter3)
	);

   weights_bias #(.SIZE(25 * 4 + 1), .NUM(9), .FILE("c3_weights_bias_x4.txt")) wb_4 (
		.clk(clk), .read(read), .out(filter4)
	);
    
   weights_bias #(.SIZE(25 * 6 + 1), .NUM(1), .FILE("c3_weights_bias_x6.txt")) wb_6 (
		.clk(clk), .read(read), .out(filter6)
	);

	generate
		for (x = 0; x < 6; x = x + 1) begin : input_maps_count
			matrix_buffer #(.BIT_WIDTH(IN_WIDTH), .SIZE(14)) mb (
				.in(in[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x]), .clk(clk), .en(en),
            .out0(matrix[x][0]), .out1(matrix[x][1]), .out2(matrix[x][2]), .out3(matrix[x][3]), .out4(matrix[x][4])
			);
		end

      for (x = 0; x < 6; x = x + 1) begin : count3

			localparam x1 = (x + 1 > 5) ? x - 5 : x + 1;
			localparam x2 = (x + 2 > 5) ? x - 4 : x + 2;
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul30 (
				.in0(matrix[x][0]), .in1(matrix[x][1]), .in2(matrix[x][2]), .in3(matrix[x][3]), .in4(matrix[x][4]),
            .filter(filter3[608*x + 199 : 608*x]), .out(out_mul3[x][0])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul31 (
				.in0(matrix[x1][0]), .in1(matrix[x1][1]), .in2(matrix[x1][2]), .in3(matrix[x1][3]), .in4(matrix[x1][4]),
            .filter(filter3[608*x + 399 : 608*x + 200]), .out(out_mul3[x][1])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul32 (
				.in0(matrix[x2][0]), .in1(matrix[x2][1]), .in2(matrix[x2][2]), .in3(matrix[x2][3]), .in4(matrix[x2][4]),
            .filter(filter3[608*x + 599 : 608*x + 400]), .out(out_mul3[x][2])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add30 (
				.in(out_mul3[x][0]), .bias(8'b0), .out(out_add3[x][0])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add31 (
				.in(out_mul3[x][1]), .bias(8'b0), .out(out_add3[x][1])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add32 (
				.in(out_mul3[x][2]), .bias(filter3[608*x + 607 : 608*x + 600]), .out(out_add3[x][2])
			);
			
			assign out_maps[x] = out_add3[x][0] + out_add3[x][1] + out_add3[x][2];
			
         relu #(.BIT_WIDTH(OUT_WIDTH)) activation3 (
				.in(out_maps[x]), .out(out[OUT_WIDTH*(x + 1) - 1 : OUT_WIDTH*x])
			);
		end
		
		for (x = 0; x < 6; x = x + 1) begin : count40

			localparam x1 = (x + 1 > 5) ? x - 5 : x + 1;
			localparam x2 = (x + 2 > 5) ? x - 4 : x + 2;
			localparam x3 = (x + 3 > 5) ? x - 3 : x + 3;

         multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul40 (
				.in0(matrix[x][0]), .in1(matrix[x][1]), .in2(matrix[x][2]), .in3(matrix[x][3]), .in4(matrix[x][4]),
            .filter(filter4[808*x + 199 : 808*x]), .out(out_mul4[x][0])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul41 (
				.in0(matrix[x1][0]), .in1(matrix[x1][1]), .in2(matrix[x1][2]), .in3(matrix[x1][3]), .in4(matrix[x1][4]),
            .filter(filter4[808*x + 399 : 808*x + 200]), .out(out_mul4[x][1])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul42 (
				.in0(matrix[x2][0]), .in1(matrix[x2][1]), .in2(matrix[x2][2]), .in3(matrix[x2][3]), .in4(matrix[x2][4]),
            .filter(filter4[808*x + 599 : 808*x + 400]), .out(out_mul4[x][2])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul43 (
				.in0(matrix[x3][0]), .in1(matrix[x3][1]), .in2(matrix[x3][2]), .in3(matrix[x3][3]), .in4(matrix[x3][4]),
            .filter(filter4[808*x + 799 : 808*x + 600]), .out(out_mul4[x][3])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add40 (
				.in(out_mul4[x][0]), .bias(8'b0), .out(out_add4[x][0])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add41 (
				.in(out_mul4[x][1]), .bias(8'b0), .out(out_add4[x][1])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add42 (
				.in(out_mul4[x][2]), .bias(8'b0), .out(out_add4[x][2])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add43 (
				.in(out_mul4[x][3]), .bias(filter4[808*x + 807 : 808*x + 800]), .out(out_add4[x][3])
			);
			
			assign out_maps[x + 6] = out_add4[x][0] + out_add4[x][1] + out_add4[x][2] + out_add4[x][3];
			
         relu #(.BIT_WIDTH(OUT_WIDTH)) activation4 (
				.in(out_maps[x + 6]), .out(out[OUT_WIDTH*(x + 7) - 1 : OUT_WIDTH*(x + 6)])
			);
		end
		
			
		for (x = 0; x < 3; x = x + 1) begin : count41
			localparam x1 = (x + 1 > 5) ? x - 5 : x + 1;
			localparam x2 = (x + 2 > 5) ? x - 4 : x + 2;
			localparam x3 = (x + 3 > 5) ? x - 3 : x + 3;
			localparam x4 = (x + 4 > 5) ? x - 2 : x + 4;
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul40 (
				.in0(matrix[x][0]), .in1(matrix[x][1]), .in2(matrix[x][2]), .in3(matrix[x][3]), .in4(matrix[x][4]),
            .filter(filter4[808*x + 5047 : 808*x + 4848]), .out(out_mul4[x + 6][0])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul41 (
				.in0(matrix[x1][0]), .in1(matrix[x1][1]), .in2(matrix[x1][2]), .in3(matrix[x1][3]), .in4(matrix[x1][4]),
            .filter(filter4[808*x + 5247 : 808*x + 5048]), .out(out_mul4[x + 6][1])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul42 (
				.in0(matrix[x3][0]), .in1(matrix[x3][1]), .in2(matrix[x3][2]), .in3(matrix[x3][3]), .in4(matrix[x3][4]),
            .filter(filter4[808*x + 5447 : 808*x + 5247]), .out(out_mul4[x + 6][2])
			);
			
			multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul43 (
				.in0(matrix[x4][0]), .in1(matrix[x4][1]), .in2(matrix[x4][2]), .in3(matrix[x4][3]), .in4(matrix[x4][4]),
            .filter(filter4[808*x + 5647 : 808*x + 5448]), .out(out_mul4[x + 6][3])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add40 (
				.in(out_mul4[x + 6][0]), .bias(8'b0), .out(out_add4[x + 6][0])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add41 (
				.in(out_mul4[x + 6][1]), .bias(8'b0), .out(out_add4[x + 6][1])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add42 (
				.in(out_mul4[x + 6][2]), .bias(8'b0), .out(out_add4[x + 6][2])
			);
			
			adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add43 (
				.in(out_mul4[x + 6][3]), .bias(filter4[808*x + 5655 : 808*x + 5648]), .out(out_add4[x + 6][3])
			);
			
			assign out_maps[x + 12] = out_add4[x + 6][0] + out_add4[x + 6][1] + out_add4[x + 6][2] + out_add4[x + 6][3];
			
         relu #(.BIT_WIDTH(OUT_WIDTH)) activation4 (
				.in(out_maps[x + 12]), .out(out[OUT_WIDTH*(x + 13) - 1 : OUT_WIDTH*(x + 12)])
			);
		end
		// 6ajkshdjkahsdjkahsdjahsdkjahsdjkhajskdhjkashdjk
		multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul60 (
			.in0(matrix[0][0]), .in1(matrix[0][1]), .in2(matrix[0][2]), .in3(matrix[0][3]), .in4(matrix[0][4]),
			.filter(filter6[199 : 0]), .out(out_mul6[0])
		);
		
		multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul61 (
			.in0(matrix[1][0]), .in1(matrix[1][1]), .in2(matrix[1][2]), .in3(matrix[1][3]), .in4(matrix[1][4]),
			.filter(filter6[399 : 200]), .out(out_mul6[1])
		);
		
		multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul62 (
			.in0(matrix[2][0]), .in1(matrix[2][1]), .in2(matrix[2][2]), .in3(matrix[2][3]), .in4(matrix[2][4]),
			.filter(filter6[599 : 400]), .out(out_mul6[2])
		);
		
		multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul63 (
			.in0(matrix[3][0]), .in1(matrix[3][1]), .in2(matrix[3][2]), .in3(matrix[3][3]), .in4(matrix[3][4]),
			.filter(filter6[799 : 600]), .out(out_mul6[3])
		);
		
		multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul64 (
			.in0(matrix[4][0]), .in1(matrix[4][1]), .in2(matrix[4][2]), .in3(matrix[4][3]), .in4(matrix[4][4]),
			.filter(filter6[999 : 800]), .out(out_mul6[4])
		);
		
		multiplication #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH)) mul65 (
			.in0(matrix[5][0]), .in1(matrix[5][1]), .in2(matrix[5][2]), .in3(matrix[5][3]), .in4(matrix[5][4]),
			.filter(filter6[1199 : 1000]), .out(out_mul6[5])
		);
		
		adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add60 (
			.in(out_mul6[0]), .bias(8'b0), .out(out_add6[0])
		);
		
		adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add61 (
			.in(out_mul6[1]), .bias(8'b0), .out(out_add6[1])
		);
		
		adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add62 (
			.in(out_mul6[2]), .bias(8'b0), .out(out_add6[2])
		);
		
		adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add63 (
			.in(out_mul6[3]), .bias(8'b0), .out(out_add6[3])
		);
		
        adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add64 (
			.in(out_mul6[4]), .bias(8'b0), .out(out_add6[4])
		);

        adder_tree #(.BIT_WIDTH(OUT_WIDTH)) add65 (
			.in(out_mul6[5]), .bias(filter6[1207 : 1200]), .out(out_add6[5])
		);
        
		assign out_maps[15] = out_add6[0] + out_add6[1] + out_add6[2] + out_add6[3] + out_add6[4] + out_add6[5];
		
		relu #(.BIT_WIDTH(OUT_WIDTH)) activation4 (
			.in(out_maps[15]), .out(out[OUT_WIDTH*16 - 1 : OUT_WIDTH*15])
		);
    endgenerate
endmodule
