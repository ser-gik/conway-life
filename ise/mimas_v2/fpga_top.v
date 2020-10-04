
module fpga_top (
    input CLK_100MHz,

    input UART_TX,
    output UART_RX,

    input [5:0] Switch,
    input [7:0] DPSwitch,

    output [7:0] LED,
    
    output [7:0] SevenSegment,
    output [2:0] SevenSegmentEnable,

    output HSync,
    output VSync,
    output [2:0] Red,
    output [2:0] Green,
    output [2:1] Blue
);
    localparam ARENA_WIDTH = 160;
    localparam ARENA_HEIGHT = 90;

    wire clk;
    wire vga_clk;
    wire reset;

    vga_clk_gen u_vga_clk_gen(
        .CLK_IN1(CLK_100MHz),
        .CLK_OUT1(vga_clk),
        .CLK_OUT2(clk)
    );

    assign reset = ~Switch[0];

    wire arena_clk;
    wire [7:0] arena_row;
    wire [7:0] arena_column;
    wire arena_cell;

    vga_image #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) u_vga_image (
        .clk(vga_clk),
        .reset(reset),
        .grid_enable(DPSwitch[0]),
        .arena_clk(arena_clk),
        .arena_row_select(arena_row),
        .arena_column_select(arena_column),
        .arena_cell_value(arena_cell),
        .HSync(HSync),
        .VSync(VSync),
        .RGB_332({Red, Green, Blue})
    );

    wire [2:0] cmd_gen;
    wire [31:0] cmd_arg0_gen;
    wire cmd_valid_gen;
    wire [2:0] cmd_cont_gen;
    wire [31:0] cmd_arg0_cont_gen;
    wire cmd_valid_cont_gen;

    wire [2:0] cmd;
    wire [31:0] cmd_arg0;
    wire cmd_valid;

    assign cmd_valid = cmd_valid_gen | cmd_valid_cont_gen;
    assign cmd = cmd_valid_cont_gen ? cmd_cont_gen : cmd_gen;
    assign cmd_arg0 = cmd_valid_cont_gen ? cmd_arg0_cont_gen : cmd_arg0_gen;

    wire cmd_ready;

    top #(
        .ARENA_WIDTH(ARENA_WIDTH),
        .ARENA_HEIGHT(ARENA_HEIGHT)
    ) u_top (
        .clk(clk),
        .reset(reset),
        .arena_rd_clk(arena_clk),
        .arena_rd_column(arena_column),
        .arena_rd_row(arena_row),
        .arena_rd_data_out(arena_cell),
        .cmd(cmd),
        .cmd_arg0(cmd_arg0),
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .cmd_res()
    );

    cmd_gen u_cmd_gen (
        .clk(clk),
        .reset(reset),
        .buttons(~Switch[4:1]),
        .cmd(cmd_gen),
        .cmd_arg0(cmd_arg0_gen),
        .cmd_valid(cmd_valid_gen)
    );

    cont_cmd_gen u_cont_cmd_gen (
        .clk(clk),
        .reset(reset),
        .switches(~DPSwitch[7:1]),
        .cmd(cmd_cont_gen),
        .cmd_arg0(cmd_arg0_cont_gen),
        .cmd_valid(cmd_valid_cont_gen)
    );

    assign LED = {7'b1000000, ~cmd_ready};
    assign SevenSegment = 8'b11111111;
    assign SevenSegmentEnable = 3'b111;

    assign UART_RX = 1'b1;

endmodule

