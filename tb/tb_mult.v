`timescale 1ns / 1ps

module tb_mult;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;

    integer ia, ib;
    integer vectors;
    integer errors;
    reg [7:0] expected;

    mult_array dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .p     (p)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);
    end

    initial begin
        vectors = 0;
        errors  = 0;
        a       = 4'd0;
        b       = 4'd0;

        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        for (ia = 0; ia < 16; ia = ia + 1) begin
            for (ib = 0; ib < 16; ib = ib + 1) begin
                a        = ia[3:0];
                b        = ib[3:0];
                expected = ia * ib;

                repeat (2) @(negedge clk);

                vectors = vectors + 1;
                if (p !== expected) begin
                    errors = errors + 1;
                    $display("MISMATCH at %0d ns: a=%0d b=%0d p=%0d expected=%0d",
                             $time, ia, ib, p, expected);
                end
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, %0d errors", vectors, errors);
        else
            $display("FAIL: %0d vectors checked, %0d errors", vectors, errors);

        $finish;
    end

endmodule
