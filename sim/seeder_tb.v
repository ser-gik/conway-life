
`default_nettype none

`timescale 1ns/100ps

module seeder_tb;
    localparam ARENA_WIDTH = 48;
    localparam ARENA_HEIGHT = 10;

    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    wire [9:0] arena_row_select;
    wire [ARENA_WIDTH-1:0] arena_columns_new;
    wire arena_write;

    arena #(
        .WIDTH(ARENA_WIDTH),
        .HEIGHT(ARENA_HEIGHT)
    ) u_arena (
        .a_clk(1'b0),
        .a_row(10'b0),
        .a_columns_out(),
        .b_clk(clk),
        .b_row(arena_row_select),
        .b_columns_in(arena_columns_new),
        .b_columns_out(),
        .b_write(arena_write)
    );

    reg reset;
    reg start;
    wire ready;
    reg [31:0] seed;

    seeder #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .ready(ready),
        .seed(seed),
        .arena_row_select(arena_row_select),
        .arena_columns_new(arena_columns_new),
        .arena_columns_write(arena_write)
    );

    initial begin
        reset = 1'b1;
        start = 1'b0;
        seed = 32'hcafebabe;
        repeat(2) @(posedge clk);
        reset = 1'b0;
        repeat(2) @(posedge clk);
        start = 1'b1;
        repeat(2) @(posedge clk);
        start = 1'b0;

        repeat(ARENA_WIDTH * ARENA_HEIGHT + 100) @(posedge clk);
        $finish;
    end

endmodule

