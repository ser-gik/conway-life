
module solver #(
    parameter ARENA_WIDTH = 10,
    parameter ARENA_HEIGHT = 10
) (
    input clk,
    input reset,

    input start,
    output ready,

    input [31:0] generations_count,

    output [9:0] arena_row_select,
    input [ARENA_WIDTH-1:0] arena_columns,
    output [ARENA_WIDTH-1:0] arena_columns_new,
    output arena_columns_write
);
    //
    // Datapath components.
    //

    // Recent 3 rows virtual queue.
    reg [ARENA_WIDTH-1:0] row_prev;
    reg [ARENA_WIDTH-1:0] row_cur;
    wire [ARENA_WIDTH-1:0] row_next;
    // Newly computed current row bits.
    wire [ARENA_WIDTH-1:0] row_cur_new;

    // Generate new row bits, based on current and adjacent to current one
    // rows. Edge bits use opposite row edge as a neighbor (i.e. row acts as
    // a virtual ring).
    genvar i;
    generate
        for (i = 0; i < ARENA_WIDTH; i = i + 1) begin: row_cur_bit_gen
            wire [2:0] top_neighbors;
            wire [2:0] bottom_neighbors;
            wire left_neighbor;
            wire right_neighbor;
            case (i)
                0 : begin
                    assign top_neighbors = {row_prev[1:0], row_prev[ARENA_WIDTH-1]};
                    assign bottom_neighbors = {row_next[1:0], row_next[ARENA_WIDTH-1]};
                    assign left_neighbor = row_cur[1];
                    assign right_neighbor = row_cur[ARENA_WIDTH-1];
                end
                ARENA_WIDTH-1 : begin
                    assign top_neighbors = {row_prev[0], row_prev[ARENA_WIDTH-1:ARENA_WIDTH-2]};
                    assign bottom_neighbors = {row_next[0], row_next[ARENA_WIDTH-1:ARENA_WIDTH-2]};
                    assign left_neighbor = row_cur[0];
                    assign right_neighbor = row_cur[ARENA_WIDTH-2];
                end
                default : begin
                    assign top_neighbors = row_prev[i+1:i-1];
                    assign bottom_neighbors = row_next[i+1:i-1];
                    assign left_neighbor = row_cur[i+1];
                    assign right_neighbor = row_cur[i-1];
                end
            endcase
            wire cell_new;
            kernel u_kernel(
                .cell_cur(row_cur[i]),
                .neighbors({top_neighbors, left_neighbor, right_neighbor, bottom_neighbors}),
                .cell_new(cell_new)
            );
            assign row_cur_new[i] = cell_new;
        end
    endgenerate

    assign arena_columns_new = row_cur_new;

    // Enables pushing data through rows queue.
    reg ctrl_update_rows_queue;

    // Row queue update.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_prev <= {ARENA_WIDTH{1'b0}};
            row_cur <= {ARENA_WIDTH{1'b0}};
        end
        else if (ctrl_update_rows_queue) begin
            row_prev <= row_cur;
            row_cur <= row_next;
        end
    end

    // Saved original row "0" (needed to later compute the last row bits).
    reg [ARENA_WIDTH-1:0] row_0_orig;
    reg [ARENA_WIDTH-1:0] row_0_orig_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_0_orig <= {ARENA_WIDTH{1'b0}};
        end
        else begin
            row_0_orig <= row_0_orig_next;
        end
    end

    // Enables original row "0" as a row queue head;
    reg ctrl_use_row_0_orig_as_next;

    // Select queue head between just read arena row or saved row "0". 
    assign row_next = ctrl_use_row_0_orig_as_next ? row_0_orig : arena_columns;

    // Index of a row that is "current"
    reg [9:0] row_cur_idx;
    reg [9:0] row_cur_idx_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row_cur_idx <= {10{1'b0}};
        end
        else begin
            row_cur_idx <= row_cur_idx_next;
        end
    end

    // Row index for arena operation.
    reg [9:0] row_select;
    reg [1:0] ctrl_row_select_mode;

    localparam [1:0] ROW_SELECT_CUR = 2'b00; 
    localparam [1:0] ROW_SELECT_PREV = 2'b01; 
    localparam [1:0] ROW_SELECT_NEXT = 2'b10; 

    localparam [9:0] LAST_ROW_IDX = ARENA_HEIGHT - 1;

    always @(*) begin
        row_select = {10{1'bx}};
        case (ctrl_row_select_mode)
            ROW_SELECT_CUR: begin
                row_select = row_cur_idx; 
            end
            ROW_SELECT_PREV: begin
                row_select = row_cur_idx == 10'd0 ? LAST_ROW_IDX : row_cur_idx - 1'b1; 
            end
            ROW_SELECT_NEXT: begin
                row_select = row_cur_idx == LAST_ROW_IDX ? 10'd0 : row_cur_idx + 1'b1; 
            end
        endcase
    end

    assign arena_row_select = row_select;

    // Arena data write control.
    reg ctrl_row_write;

    assign arena_columns_write = ctrl_row_write;

    reg [31:0] remaining_gen_count;
    reg [31:0] remaining_gen_count_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            remaining_gen_count <= {32{1'b0}};
        end
        else begin
            remaining_gen_count <= remaining_gen_count_next;
        end
    end

    //
    // Controller.
    //

    // Allowed states space.
    localparam [2:0] IDLE = 3'b000;
    localparam [2:0] READ_ROW_LAST = 3'b001;
    localparam [2:0] READ_ROW_0 = 3'b010;
    localparam [2:0] READ_ROW_1 = 3'b011;
    localparam [2:0] WRITE_CUR_ROW_NEW = 3'b100;
    localparam [2:0] READ_ROW_NEXT = 3'b101;
    localparam [2:0] RESERVED_6 = 3'b110;
    localparam [2:0] RESERVED_7 = 3'b111;

    reg [2:0] state;
    reg [2:0] state_next;

    assign ready = state == IDLE;

    always @(*) begin
        state_next = state;
        row_cur_idx_next = row_cur_idx;
        row_0_orig_next = row_0_orig;
        remaining_gen_count_next = remaining_gen_count;
        ctrl_row_write = 1'b0;
        ctrl_use_row_0_orig_as_next = 1'b0;
        ctrl_update_rows_queue = 1'b0;
        ctrl_row_select_mode = 2'bxx;
        case (state)
            IDLE: begin
                if (start && generations_count != 32'd0) begin
                    remaining_gen_count_next = generations_count;
                    row_cur_idx_next = 10'd0;
                    state_next = READ_ROW_LAST;
                end
            end
            READ_ROW_LAST: begin
                ctrl_row_select_mode = ROW_SELECT_PREV;
                state_next = READ_ROW_0;
            end
            READ_ROW_0: begin
                ctrl_update_rows_queue = 1'b1;
                ctrl_row_select_mode = ROW_SELECT_CUR;
                state_next = READ_ROW_1;
            end
            READ_ROW_1: begin
                ctrl_update_rows_queue = 1'b1;
                ctrl_row_select_mode = ROW_SELECT_NEXT;
                row_0_orig_next = arena_columns;
                state_next = WRITE_CUR_ROW_NEW;
            end
            WRITE_CUR_ROW_NEW: begin
                ctrl_update_rows_queue = 1'b1;
                ctrl_row_write = 1'b1;
                ctrl_row_select_mode = ROW_SELECT_CUR;
                if (row_cur_idx == LAST_ROW_IDX) begin
                    ctrl_use_row_0_orig_as_next = 1'b1;
                    if (remaining_gen_count == 32'b1) begin
                        state_next = IDLE;
                    end
                    else begin
                        remaining_gen_count_next = remaining_gen_count - 1'b1;
                        row_cur_idx_next = 10'd0;
                        state_next = READ_ROW_LAST;
                    end
                end
                else begin
                    row_cur_idx_next = row_cur_idx + 1'b1;
                    state_next = READ_ROW_NEXT;
                end
            end
            READ_ROW_NEXT: begin
                ctrl_row_select_mode = ROW_SELECT_NEXT;
                state_next = WRITE_CUR_ROW_NEW;
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

endmodule

