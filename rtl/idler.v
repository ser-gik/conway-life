
module idler #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
) (
    input start,
    output ready,
    output [7:0] arena_row_select,
    output [ARENA_WIDTH-1:0] arena_columns_new,
    output arena_columns_write
);

    assign ready = 1'b1; 
    assign arena_row_select = {8{1'bx}};
    assign arena_columns_new = {ARENA_WIDTH{1'bx}};
    assign arena_columns_write = 1'b0;

endmodule

