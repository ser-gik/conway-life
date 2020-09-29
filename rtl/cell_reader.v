
module cell_reader #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
) (
    input clk,
    input reset,

    input start,
    output ready,

    input [7:0] cell_column,
    input [7:0] cell_row,
    output cell_value,

    output [7:0] arena_row_select,
    input [ARENA_WIDTH-1:0] arena_columns
);
    assign ready = 1'b1; // Read is always 1-cycle

    assign arena_row_select = start ? cell_row : {8{1'bx}};
    assign cell_value = arena_columns[cell_column]; // TODO do we want to flip bit order?

endmodule

