
`timescale 1ns/100ps

module kernel_tb;
    reg cell_cur;
    reg [7:0] neighbors;
    wire cell_new;

    kernel uut(
        .cell_cur(cell_cur),
        .neighbors(neighbors),
        .cell_new(cell_new)
    );

    integer i;
    initial begin
        cell_cur = 1'b0;
        for (i = 0; i < 256; i = i + 1) begin
            #1 neighbors = i;
        end
        cell_cur = 1'b1;
        for (i = 0; i < 256; i = i + 1) begin
            #1 neighbors = i;
        end
        $finish;
    end

endmodule

