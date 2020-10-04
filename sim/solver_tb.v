
`timescale 1ns/100ps

module solver_tb;
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

    wire [7:0] arena_row_select;
    wire [9:0] arena_columns;
    wire [9:0] arena_columns_new;
    wire arena_write;

    arena #(
        .WIDTH(ARENA_WIDTH),
        .HEIGHT(ARENA_HEIGHT)
    ) u_arena (
        .a_clk(1'b0),
        .a_row(8'b0),
        .a_columns_out(),
        .b_clk(clk),
        .b_row(arena_row_select),
        .b_columns_in(arena_columns_new),
        .b_columns_out(arena_columns),
        .b_write(arena_write)
    );

    reg start;
    wire ready;
    reg [31:0] generations_count;

    solver #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .ready(ready),
        .generations_count(generations_count),
        .arena_row_select(arena_row_select),
        .arena_columns(arena_columns),
        .arena_columns_new(arena_columns_new),
        .arena_columns_write(arena_write)
    );

    task solve(
        input [128*8:1] memory_name,
        input [31:0] generations
    );
    begin
        $readmemb(memory_name, u_arena.RAM);
        @(posedge clk);
        generations_count = generations;
        start = 1'b1;
        @(posedge clk);
        @(negedge clk);
        start = 1'b0;
        wait(ready);
        @(posedge clk);
    end
    endtask

    initial begin
        reset = 1'b1;
        @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        solve({memories_directory, "/arena_0_10x10.mem"}, 32'd1);
        solve({memories_directory, "/arena_1_10x10.mem"}, 32'd1);
        solve({memories_directory, "/arena_2_10x10.mem"}, 32'd10);
        solve({memories_directory, "/arena_3_10x10.mem"}, 32'd5);
        $finish;
    end

endmodule

