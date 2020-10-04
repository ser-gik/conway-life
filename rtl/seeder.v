
module seeder #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
) (
    input clk,
    input reset,

    input start,
    output ready,

    input [31:0] seed,

    output [9:0] arena_row_select,
    output [ARENA_WIDTH-1:0] arena_columns_new,
    output arena_columns_write
);
    localparam [9:0] MAX_COLUMN = ARENA_WIDTH - 1;
    localparam [9:0] MAX_ROW = ARENA_HEIGHT - 1;

    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] LOADED = 2'b01;
    localparam [1:0] RUNNING = 2'b10;

    reg [1:0] state;
    reg [1:0] state_next;

    reg [31:0] lfsr;
    reg [31:0] lfsr_next;
    reg [ARENA_WIDTH-1:0] columns_seed;
    reg [9:0] cur_row;
    reg [9:0] cur_row_next;
    reg [9:0] cur_column;
    reg [9:0] cur_column_next;
    reg row_write;

    always @(*) begin
        state_next = state;
`ifdef __ICARUS__
        // Cyclic shift for simulation.
        lfsr_next = {lfsr[30:0], lfsr[31]};
`else
        lfsr_next = {lfsr[30:0], lfsr[28] ^ lfsr[18]};
`endif
        cur_row_next = cur_row;
        cur_column_next = cur_column;
        row_write = 1'b0;

        case (state)
            IDLE: begin
                state_next = start ? LOADED : IDLE;
                if (start) begin
                    lfsr_next = seed;
                end
            end
            LOADED: begin
                state_next = RUNNING;
                cur_row_next = 10'b0;
                cur_column_next = 10'b0;
            end
            RUNNING: begin
                state_next = RUNNING;
                if (cur_column == MAX_COLUMN) begin
                    row_write = 1'b1;
                    if (cur_row == MAX_ROW) begin
                        state_next = IDLE;
                    end
                    else begin
                        cur_column_next = 10'b0;
                        cur_row_next = cur_row + 1'b1;
                    end
                end
                else begin
                    cur_column_next = cur_column + 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 32'b0;
        end
        else begin
            lfsr <= lfsr_next;
        end
    end

    always @(posedge clk) begin
        columns_seed <= {columns_seed[ARENA_WIDTH-2:0], lfsr[31]};
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cur_row <= 10'b0;
        end
        else begin
            cur_row <= cur_row_next;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cur_column <= 10'b0;
        end
        else begin
            cur_column <= cur_column_next;
        end
    end

    assign ready = state == IDLE;
    assign arena_row_select = cur_row;
    assign arena_columns_new = columns_seed;
    assign arena_columns_write = row_write;

endmodule

