
`timescale 1ns/100ps

module cell_reader_tb;
    localparam ARENA_WIDTH = 10;
    localparam ARENA_HEIGHT = 10;

    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset;

    reg [7:0] arena_row_select_init;
    wire [7:0] arena_row_select_uut;
    reg row_select_init;

    wire [9:0] arena_columns;
    reg [9:0] arena_columns_new;
    reg arena_write;

    arena #(
        .WIDTH(ARENA_WIDTH),
        .HEIGHT(ARENA_HEIGHT)
    ) u_arena (
        .a_clk(1'b0),
        .a_row(8'b0),
        .a_columns_out(),
        .b_clk(clk),
        .b_row(row_select_init ? arena_row_select_init : arena_row_select_uut),
        .b_columns_in(arena_columns_new),
        .b_columns_out(arena_columns),
        .b_write(arena_write)
    );

    reg start;
    wire ready;
    reg [7:0] cell_column;
    reg [7:0] cell_row;
    wire cell_value;

    reg cell_registered;

    always @(posedge clk) begin
        cell_registered <= cell_value;
    end

    cell_reader #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .ready(ready),
        .cell_column(cell_column),
        .cell_row(cell_row),
        .cell_value(cell_value),
        .arena_row_select(arena_row_select_uut),
        .arena_columns(arena_columns)
    );

    integer i;

    initial begin
        reset = 1'b1;
        start = 1'b0;
        @(posedge clk);
        reset = 1'b0;

        row_select_init = 1'b1;
        arena_write = 1'b1;

        arena_row_select_init = 8'd0;
        arena_columns_new = 10'b1;
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            @(negedge clk);
            arena_row_select_init = arena_row_select_init + 8'd1;
            arena_columns_new = {arena_columns_new[8:0], 1'b0};
        end

        arena_write = 1'b0;
        row_select_init = 1'b0;

        cell_column = 8'd3;
        cell_row = 8'd0;
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;
            repeat(4) @(posedge clk);
            cell_row = cell_row + 8'd1;
        end

        $finish;
    end

endmodule

