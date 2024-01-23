module matrix_buffer #(parameter BIT_WIDTH = 8, SIZE = 32) (
    input signed [BIT_WIDTH - 1 : 0] in,
    input clk, en,
    output signed [BIT_WIDTH*5 - 1 : 0] out0, out1, out2, out3, out4
);
    reg signed [BIT_WIDTH - 1 : 0] matrix [4:0] [4:0];

    wire signed [BIT_WIDTH - 1 : 0] out_rb [3:0];

    integer i;

    row_buffer_4 #(.LENGTH(SIZE), .BIT_WIDTH(BIT_WIDTH)) rb (
        .in(in), .clk(clk), .en(en),
        .out0(out_rb[0]), .out1(out_rb[1]), .out2(out_rb[2]), .out3(out_rb[3])
    );

    always @(posedge clk) begin
        if (en) begin
            for (i = 4; i > 0; i = i - 1) begin
                matrix[0][i] <= matrix[0][i - 1];
                matrix[1][i] <= matrix[1][i - 1];
                matrix[2][i] <= matrix[2][i - 1];
                matrix[3][i] <= matrix[3][i - 1];
                matrix[4][i] <= matrix[4][i - 1];
            end
            matrix[0][0] <= in;
            matrix[1][0] <= out_rb[0];
            matrix[2][0] <= out_rb[1];
            matrix[3][0] <= out_rb[2];
            matrix[4][0] <= out_rb[3];
        end
    end

    genvar x;

    generate
        for (x = 0; x < 5; x = x + 1) begin : row_count
            assign out0[BIT_WIDTH*(x + 1) - 1 : BIT_WIDTH*x] = matrix[0][x];
            assign out1[BIT_WIDTH*(x + 1) - 1 : BIT_WIDTH*x] = matrix[1][x];
            assign out2[BIT_WIDTH*(x + 1) - 1 : BIT_WIDTH*x] = matrix[2][x];
            assign out3[BIT_WIDTH*(x + 1) - 1 : BIT_WIDTH*x] = matrix[3][x];
            assign out4[BIT_WIDTH*(x + 1) - 1 : BIT_WIDTH*x] = matrix[4][x];
        end
    endgenerate
endmodule
