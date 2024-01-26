module pooling_buffer #(parameter BIT_WIDTH = 32) (
    input clk,
    input en,
    input signed[BIT_WIDTH-1:0] in1, in2,
    output [BIT_WIDTH-1:0] out1, out2
);

parameter SIZE = 2;

	reg [BIT_WIDTH-1:0] pb1 [SIZE-1:0];
	reg [BIT_WIDTH-1:0] pb2 [SIZE-1:0];
	integer i;
	
	always @(posedge clk) begin
		if (en)	begin
			for(i = SIZE - 1; i > 0; i = i - 1) begin
				pb1[i] <= pb1[i-1];
				pb2[i] <= pb2[i-1];
			end
			pb1[0] <= in1;
			pb2[0] <= in2;
		end
	end
	assign out1 = pb1[SIZE-1];
	assign out2 = pb2[SIZE-1];
endmodule