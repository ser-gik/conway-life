
`include "command.vh"

module top #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
)(
    input clk,
    input reset,

    // 1-cycle arena read port.
    input arena_rd_clk,
    input [9:0] arena_rd_column,
    input [9:0] arena_rd_row,
    output arena_rd_data_out,

    // control port
    input [2:0] cmd,
    input [31:0] cmd_arg0,
    input cmd_valid,
    output cmd_ready,
    output [31:0] cmd_res
);
    wire [ARENA_WIDTH-1:0] arena_rd_columns;

    wire [9:0] row_select;
    wire [ARENA_WIDTH-1:0] columns_new;
    wire columns_write;

    wire [ARENA_WIDTH-1:0] columns;

    arena #(
        .WIDTH(ARENA_WIDTH),
        .HEIGHT(ARENA_HEIGHT)
    ) u_arena (
        .a_clk(arena_rd_clk),
        .a_row(arena_rd_row),
        .a_columns_out(arena_rd_columns),
        .b_clk(clk),
        .b_row(row_select),
        .b_columns_out(columns),
        .b_columns_in(columns_new),
        .b_write(columns_write)
    );

    assign arena_rd_data_out = arena_rd_columns[arena_rd_column]; // TODO check mux

    wire [1:0] agent_select;

    wire [9:0] row_select_idler;
    wire [ARENA_WIDTH-1:0] columns_new_idler;
    wire columns_write_idler;
    wire [9:0] row_select_solver;
    wire [ARENA_WIDTH-1:0] columns_new_solver;
    wire columns_write_solver;
    wire [9:0] row_select_cell_reader;
    wire [ARENA_WIDTH-1:0] columns_new_cell_reader;
    wire columns_write_cell_reader;
    wire [9:0] row_select_seeder;
    wire [ARENA_WIDTH-1:0] columns_new_seeder;
    wire columns_write_seeder;

    mux_4x1 #(.WIDTH(10)) u_mux_row_select (
        .select(agent_select),
        .in0(row_select_idler),
        .in1(row_select_solver),
        .in2(row_select_cell_reader),
        .in3(row_select_seeder),
        .out(row_select)
    );

    mux_4x1 #(.WIDTH(ARENA_WIDTH)) u_mux_columns_new (
        .select(agent_select),
        .in0(columns_new_idler),
        .in1(columns_new_solver),
        .in2(columns_new_cell_reader),
        .in3(columns_new_seeder),
        .out(columns_new)
    );

    mux_4x1 #(.WIDTH(1)) u_mux_row_columns_write (
        .select(agent_select),
        .in0(columns_write_idler),
        .in1(columns_write_solver),
        .in2(columns_write_cell_reader),
        .in3(columns_write_seeder),
        .out(columns_write)
    );

    wire ready_idler;
    wire ready_solver;
    wire ready_cell_reader;
    wire ready_seeder;
    wire start_idler;
    wire start_solver;
    wire start_cell_reader;
    wire start_seeder;

    idler #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) u_idler (
        .start(start_idler),
        .ready(ready_idler),
        .arena_row_select(row_select_idler),
        .arena_columns_new(columns_new_idler),
        .arena_columns_write(columns_write_idler)
    );

    solver #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) u_solver (
        .clk(clk),
        .reset(reset),
        .start(start_solver),
        .ready(ready_solver),
        .generations_count(cmd_arg0),
        .arena_row_select(row_select_solver),
        .arena_columns(columns),
        .arena_columns_new(columns_new_solver),
        .arena_columns_write(columns_write_solver)
    );

    wire cell_reader_cell_value;

    cell_reader #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) u_cell_reader (
        .clk(clk),
        .reset(reset),
        .start(start_cell_reader),
        .ready(ready_cell_reader),
        .cell_column(cmd_arg0[19:10]),
        .cell_row(cmd_arg0[9:0]),
        .cell_value(cell_reader_cell_value),
        .arena_row_select(row_select_cell_reader),
        .arena_columns(columns)
    );
    assign columns_new_cell_reader = {ARENA_WIDTH{1'bx}};
    assign columns_write_cell_reader = 1'b0;

    seeder #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) u_seeder (
        .clk(clk),
        .reset(reset),
        .start(start_seeder),
        .ready(ready_seeder),
        .seed(cmd_arg0),
        .arena_row_select(row_select_seeder),
        .arena_columns_new(columns_new_seeder),
        .arena_columns_write(columns_write_seeder)
    );

    mux_4x1 #(.WIDTH(32)) u_mux_cmd_res (
        .select(agent_select),
        .in0({32{1'bx}}),
        .in1({32{1'bx}}),
        .in2({{31{1'b0}}, cell_reader_cell_value}),
        .in3({32{1'bx}}),
        .out(cmd_res)
    );


    agent_selector u_agent_selector (
        .clk(clk),
        .reset(reset),
        .agent_select_in(cmd[1:0]),
        .agent_select_out(agent_select),
        .agent_0_start(start_idler),
        .agent_1_start(start_solver),
        .agent_2_start(start_cell_reader),
        .agent_3_start(start_seeder),
        .agent_0_ready(ready_idler),
        .agent_1_ready(ready_solver),
        .agent_2_ready(ready_cell_reader),
        .agent_3_ready(ready_seeder),
        .start(cmd_valid),
        .ready(cmd_ready)
    );

endmodule

