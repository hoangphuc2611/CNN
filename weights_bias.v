module weights_bias #(parameter SIZE = 26, NUM = 6, BIT_WIDTH = 8, FILE = "blank.txt")(
	input clk, read,
	output reg [(BIT_WIDTH*SIZE*NUM)-1:0] out
);
	reg [BIT_WIDTH-1:0] para [SIZE*NUM - 1:0];
	
	reg [31:0] i;
	
	initial begin
		$readmemh(FILE, para);
	end
	
	always @(posedge clk) begin
		for (i = 0; i < (SIZE*NUM); i = i + 1) begin
			// [ +: ] indicates a part-select increment
			out[BIT_WIDTH*i +: BIT_WIDTH] <= read ? para[i] : 8'bz;
		end
	end
endmodule
