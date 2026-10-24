module mult_array (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] a,
    input  wire [3:0] b,
    output reg  [7:0] p
);

    reg [3:0] a_r, b_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_r <= 4'd0;
            b_r <= 4'd0;
        end else begin
            a_r <= a;
            b_r <= b;
        end
    end

    wire [15:0] pp;

    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_pp_row
            for (j = 0; j < 4; j = j + 1) begin : g_pp_bit
                assign pp[(i<<2) + j] = a_r[j] & b_r[i];
            end
        end
    endgenerate

    wire [15:0] r;
    wire [15:0] s;
    wire [19:0] c;
    wire [7:0]  prod;

    assign prod[0] = pp[0];
    assign r[3:0]  = {1'b0, pp[3], pp[2], pp[1]};

    generate
        for (i = 1; i < 4; i = i + 1) begin : g_row
            assign c[((i<<2)+i)] = 1'b0;

            for (j = 0; j < 4; j = j + 1) begin : g_fa
                full_adder u_fa (
                    .a    (pp[(i<<2) + j]),
                    .b    (r[((i-1)<<2) + j]),
                    .cin  (c[((i<<2)+i) + j]),
                    .sum  (s[(i<<2) + j]),
                    .cout (c[((i<<2)+i) + j + 1])
                );
            end

            assign prod[i]     = s[(i<<2)];
            assign r[(i<<2) +: 4] = {c[((i<<2)+i) + 4], s[(i<<2) + 3], s[(i<<2) + 2], s[(i<<2) + 1]};
        end
    endgenerate

    assign prod[7:4] = r[15:12];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            p <= 8'd0;
        else
            p <= prod;
    end

endmodule
