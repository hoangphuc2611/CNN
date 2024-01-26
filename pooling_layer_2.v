/*module pooling_layer_2 #(parameter BIT_WIDTH = 16, MAPS = 6)(
	 input clk,
    input en,
	 input signed[BIT_WIDTH-1:0] in,
	 output signed[BIT_WIDTH-1:0] pool2_out
);


wire signed[BIT_WIDTH-1:0] C1_out[MAPS-1:0];
wire signed[BIT_WIDTH-1:0] C1_relu[MAPS-1:0];

genvar x;

generate
	for (x = 0; x < 6; x = x+1) begin : S2_op
		pooling_2x2 #(.BIT_WIDTH(BIT_WIDTH)) S2_POOL (
			.clk(clk),
			.en(S2_en),
			.in1(outC1), .in2(C1_relu),
			.maxOut(pool2_out)
		);
	end
endgenerate 

endmodule */