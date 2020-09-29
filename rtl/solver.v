
module solver #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
) (
    input clk,
    input reset,

    input start,
    output ready,

    input [31:0] generations_count,

    output [7:0] arena_row_select,
    input [ARENA_WIDTH-1:0] arena_columns,
    output [ARENA_WIDTH-1:0] arena_columns_new,
    output arena_columns_write
);

    // TODO implement me

    assign ready = 1'b1; 
    assign arena_row_select = 8'b0;
    assign arena_columns_new = {ARENA_WIDTH{1'b0}};
    assign arena_columns_write = 1'b0;

endmodule

