
`timescale 1ns/100ps

module cell_reader_tb;
    reg [1:8*128] memories_directory;
    initial begin
        if ($value$plusargs("MEMORIES_DIR+%s", memories_directory)) begin
        end
    end

    localparam ARENA_WIDTH = 10;
    localparam ARENA_HEIGHT = 10;

    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset;

    wire [9:0] arena_row_select;
    wire [9:0] arena_columns;

    arena #(
        .WIDTH(ARENA_WIDTH),
        .HEIGHT(ARENA_HEIGHT)
    ) u_arena (
        .a_clk(1'b0),
        .a_row(10'b0),
        .a_columns_out(),
        .b_clk(clk),
        .b_row(arena_row_select),
        .b_columns_in({ARENA_WIDTH{1'b0}}),
        .b_columns_out(arena_columns),
        .b_write(1'b0)
    );

    reg start;
    wire ready;
    reg [9:0] cell_column;
    reg [9:0] cell_row;
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
        .arena_row_select(arena_row_select),
        .arena_columns(arena_columns)
    );

    integer i;

    initial begin
        $readmemb({memories_directory, "/arena_0_10x10.mem"}, u_arena.RAM);

        reset = 1'b1;
        start = 1'b0;
        @(posedge clk);
        reset = 1'b0;

        cell_column = 10'd3;
        cell_row = 10'd0;
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;
            repeat(4) @(posedge clk);
            cell_row = cell_row + 1'd1;
        end

        $finish;
    end

endmodule

