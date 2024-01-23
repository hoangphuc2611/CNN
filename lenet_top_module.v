module lenet_top_module #(parameter IMAGE_SIZE = 32, IN_WIDTH = 8, OUT_WIDTH = 32) (
	input clk, rst,
	input signed [IN_WIDTH - 1 : 0] input_pixel,
	output [3:0] out
);

	parameter C1_MAPS = 6;
	parameter C3_MAPS = 16;
	parameter C5_MAPS = 120;
	
	//	CONTROLLER
	wire read, en_S2, en_C3, en_S4, en_C5;
	controller #(.SIZE(IMAGE_SIZE)) ctrl (
		.clk(clk), .read(read),
		.en_S2(en_S2), .en_C3(en_C3), .en_S4(en_S4), .en_C5(en_C5)
	);
	
	// CONVOLUTIONAL LAYER 1
	wire [OUT_WIDTH*C1_MAPS - 1 : 0] out_C1;
	
	convolutional_layer_1 #(.IN_WIDTH(IN_WIDTH), .OUT_WIDTH(OUT_WIDTH), .MAPS(C1_MAPS) (
		.in(input_pixel), .clk(clk), .en(1'b1), .read(read), .out(out_C1)
	);	
	
	// POOLING LAYER 2
	wire [OUT_WIDTH*C1_MAPS - 1 : 0] out_S2;
	
	// CONVOLUTIONAL LAYER 3
	wire [OUT_WIDTH*C3_MAPS - 1 : 0] out_C3;
	
	convolutional_layer_3 #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH), .MAPS(C3_MAPS) (
		.in(out_S2), .clk(clk), .en(en_C3), .read(read), .out(out_C3)
	);	
	
	// POOLING LAYER 4
	wire [OUT_WIDTH*C3_MAPS - 1 : 0] out_S4;
	
	// CONVOLUTIONAL LAYER 5
	wire [OUT_WIDTH*C5_MAPS - 1 : 0] out_C5;
	
	convolutional_layer_5 #(.IN_WIDTH(OUT_WIDTH), .OUT_WIDTH(OUT_WIDTH), .MAPS(C5_MAPS) (
		.in(out_S4), .clk(clk), .en(en_C5), .read(read), .out(out_C5)
	);
	
	//	FULLY CONNECTED LAYER 6
	
endmodule
