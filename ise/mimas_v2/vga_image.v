
module vga_image #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
)(
    input clk,
    input reset,

    input grid_enable,

    output arena_clk,
    output [7:0] arena_row_select,
    output [7:0] arena_column_select,
    input arena_cell_value,

    output HSync,
    output VSync,

    output [7:0] RGB_332
);
    assign arena_clk = clk;

    wire[10:0] pixel_x;
    wire[9:0] pixel_y;
    wire pixel_visible;
    wire hsync_raw;
    wire vsync_raw;

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
        .pixel_clk(clk),
        .reset_n(~reset),
        .hsync(hsync_raw),
        .vsync(vsync_raw),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_visible(pixel_visible)
    );

    reg HSync;
    reg VSync;
    always @(posedge clk) begin
        HSync <= hsync_raw;
        VSync <= vsync_raw;
    end

    // Each cell is drawn as a 8x8 pixels square
    assign arena_column_select = pixel_x[10:3];
    assign arena_row_select = {1'b0, pixel_y[9:3]};

    wire is_arena;
    assign is_arena = pixel_visible
                    && arena_column_select < ARENA_WIDTH
                    && arena_row_select < ARENA_HEIGHT;

    wire is_grid;
    // 1-pixel wide grid lines
    assign is_grid = pixel_x[2:0] == 3'b000 || pixel_y[2:0] == 3'b000;

    reg [7:0] RGB_332;
    reg [7:0] RGB_332_next;

    always @(*) begin
        RGB_332_next = 8'b000000;
        if (is_arena) begin
            if (grid_enable && is_grid) begin
                RGB_332_next = 8'b00011100;
            end
            else if (arena_cell_value) begin
                RGB_332_next = 8'b00000011;
            end
        end
    end

    always @(posedge clk) begin
        RGB_332 <= RGB_332_next;
    end

endmodule

