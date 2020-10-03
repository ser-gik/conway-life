
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

    // No-op, just hang for a few cycles.
    
    reg busy;
    reg busy_next;
    reg [3:0] ticks;
    reg [3:0] ticks_next;

    always @(*) begin
        busy_next = 1'b0;
        ticks_next = 4'bxxxx;
        case (busy)
            1'b0: begin
                if (start) begin
                    busy_next = 1'b1;
                    ticks_next = 4'b0000;
                end
            end
            1'b1: begin
                if (ticks == 4'b1111) begin
                    busy_next = 1'b0;
                end
                else begin
                    busy_next = 1'b1;
                    ticks_next = ticks + 1'b1;
                end
            end
        endcase
    end


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy <= 1'b0;
        end
        else begin
            busy <= busy_next;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ticks <= 4'b0000;
        end
        else begin
            ticks <= ticks_next;
        end
    end

    assign ready = ~busy; 
    assign arena_row_select = 8'b0;
    assign arena_columns_new = {ARENA_WIDTH{1'b0}};
    assign arena_columns_write = 1'b0;

endmodule

