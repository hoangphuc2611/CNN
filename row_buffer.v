module row_buffer #(parameter LENGTH = 32, BIT_WIDTH = 8)(
	input [BIT_WIDTH-1:0] in,
	input clk, en,
	output [BIT_WIDTH-1:0] out
);
	reg [BIT_WIDTH-1:0] rb [LENGTH-1:0];
	integer i;
	
	always @(posedge clk) begin
		if (en)	begin
			for(i = LENGTH - 1; i > 0; i = i - 1) begin
				rb[i] <= rb[i-1];
			end
			rb[0] <= in;
		end
	end
	assign out = rb[LENGTH-1];
endmodule
