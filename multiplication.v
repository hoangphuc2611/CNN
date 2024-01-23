module multiplication #(parameter IN_WIDTH = 8, OUT_WIDTH = 32) (
    input signed [IN_WIDTH*5 - 1 : 0] in0, in1, in2, in3, in4,
    input signed [199 : 0] filter,
    output signed [OUT_WIDTH*25 - 1 : 0] out
);
    wire signed [IN_WIDTH - 1 : 0] matrix [4:0][4:0];
	
    wire signed [7:0] array_filter [24:0];
	
    genvar x, y;

    generate
		for (x = 0; x < 25; x = x + 1) begin : filter_count
			assign array_filter[x] = filter[8*(x + 1) - 1 : 8*x];
		end
		
      for (x = 0; x < 5; x = x + 1) begin : matrix_count
			assign matrix[0][x] = in0[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x];
         assign matrix[1][x] = in1[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x];
			assign matrix[2][x] = in2[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x];
         assign matrix[3][x] = in3[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x];
         assign matrix[4][x] = in4[IN_WIDTH*(x + 1) - 1 : IN_WIDTH*x];
			
			assign out[OUT_WIDTH*(x + 1) - 1 : OUT_WIDTH*x] = matrix[0][x] * array_filter[x];
			assign out[OUT_WIDTH*(x + 6) - 1 : OUT_WIDTH*(x + 5)] = matrix[1][x] * array_filter[x + 5];
			assign out[OUT_WIDTH*(x + 11) - 1 : OUT_WIDTH*(10 + x)] = matrix[2][x] * array_filter[x + 10];
			assign out[OUT_WIDTH*(x + 16) - 1 : OUT_WIDTH*(15 + x)] = matrix[3][x] * array_filter[x + 15];
			assign out[OUT_WIDTH*(x + 21) - 1 : OUT_WIDTH*(20 + x)] = matrix[4][x] * array_filter[x + 20];
		end
    endgenerate
endmodule
