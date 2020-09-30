
module vga_image #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
)(
    input clk,
    input reset,

    output arena_clk,
    output [7:0] arena_row_select,
    output [7:0] arena_column_select,
    input arena_cell_value,

    output HSync,
    output VSync,

    output [7:0] RGB_332
);

    wire vga_clk;





    assign arena_clk = vga_clk;

    wire[10:0] pixel_x;
    wire[9:0] pixel_y;
    wire pixel_visible;

    vga_sync_generator #(
        .HSIZE(1280),
        .HFPORCH(110),
        .HSYNC(40),
        .HBPORCH(220),
        .HSYNC_POSITIVE(1),
        .VSIZE(720),
        .VFPORCH(5),
        .VSYNC(5),
        .VBPORCH(20),
        .VSYNC_POSITIVE(1)
    ) u_vga_sync_generator (
    .pixel_clk(vga_clk),
    .reset_n(~reset),
    .hsync(HSync),
    .vsync(VSync),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .line_start(),
    .frame_start(),
    .pixel_visible(pixel_visible)
    );

    assign arena_column_select = pixel_x[10:3];
    assign arena_row_select = {1'b0, pixel_y[9:3]};

    wire is_arena;
    assign is_arena = pixel_visible
                    && arena_column_select < ARENA_WIDTH
                    && arena_row_select < ARENA_HEIGHT;

    wire is_grid;
    assign is_grid = pixel_x[2:0] == 3'b000 && pixel_y[2:0] == 3'b000;

    assign RGB_332 = is_arena ? (is_grid ? 8'b00011100 : 8'b00000011) : 8'b00000000;

endmodule

