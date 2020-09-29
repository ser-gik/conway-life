//
// Combinatorial logic for next cell state.
//
// Rules as below:
// 1. Any live cell with two or three live neighbours survives.
// 2. Any dead cell with three live neighbours becomes a live cell.
// 3. All other live cells die in the next generation. Similarly, all other dead cells stay dead.
//
// 1'b1 mean cell is live.
//
// Logic is optimised for 6-input LUTs.
//

module kernel (
    input cell_cur,
    input [7:0] neighbors,
    output cell_new
);
    reg [2:0] live_neighbors_part_count;

    always @(*) begin
        case (neighbors[7:2])
            6'b000000: live_neighbors_part_count = 3'd0;
            6'b000001: live_neighbors_part_count = 3'd1;
            6'b000010: live_neighbors_part_count = 3'd1;
            6'b000011: live_neighbors_part_count = 3'd2;
            6'b000100: live_neighbors_part_count = 3'd1;
            6'b000101: live_neighbors_part_count = 3'd2;
            6'b000110: live_neighbors_part_count = 3'd2;
            6'b000111: live_neighbors_part_count = 3'd3;
            6'b001000: live_neighbors_part_count = 3'd1;
            6'b001001: live_neighbors_part_count = 3'd2;
            6'b001010: live_neighbors_part_count = 3'd2;
            6'b001011: live_neighbors_part_count = 3'd3;
            6'b001100: live_neighbors_part_count = 3'd2;
            6'b001101: live_neighbors_part_count = 3'd3;
            6'b001110: live_neighbors_part_count = 3'd3;
            6'b001111: live_neighbors_part_count = 3'd4;
            6'b010000: live_neighbors_part_count = 3'd1;
            6'b010001: live_neighbors_part_count = 3'd2;
            6'b010010: live_neighbors_part_count = 3'd2;
            6'b010011: live_neighbors_part_count = 3'd3;
            6'b010100: live_neighbors_part_count = 3'd2;
            6'b010101: live_neighbors_part_count = 3'd3;
            6'b010110: live_neighbors_part_count = 3'd3;
            6'b010111: live_neighbors_part_count = 3'd4;
            6'b011000: live_neighbors_part_count = 3'd2;
            6'b011001: live_neighbors_part_count = 3'd3;
            6'b011010: live_neighbors_part_count = 3'd3;
            6'b011011: live_neighbors_part_count = 3'd4;
            6'b011100: live_neighbors_part_count = 3'd3;
            6'b011101: live_neighbors_part_count = 3'd4;
            6'b011110: live_neighbors_part_count = 3'd4;
            6'b011111: live_neighbors_part_count = 3'd5;
            6'b100000: live_neighbors_part_count = 3'd1;
            6'b100001: live_neighbors_part_count = 3'd2;
            6'b100010: live_neighbors_part_count = 3'd2;
            6'b100011: live_neighbors_part_count = 3'd3;
            6'b100100: live_neighbors_part_count = 3'd2;
            6'b100101: live_neighbors_part_count = 3'd3;
            6'b100110: live_neighbors_part_count = 3'd3;
            6'b100111: live_neighbors_part_count = 3'd4;
            6'b101000: live_neighbors_part_count = 3'd2;
            6'b101001: live_neighbors_part_count = 3'd3;
            6'b101010: live_neighbors_part_count = 3'd3;
            6'b101011: live_neighbors_part_count = 3'd4;
            6'b101100: live_neighbors_part_count = 3'd3;
            6'b101101: live_neighbors_part_count = 3'd4;
            6'b101110: live_neighbors_part_count = 3'd4;
            6'b101111: live_neighbors_part_count = 3'd5;
            6'b110000: live_neighbors_part_count = 3'd2;
            6'b110001: live_neighbors_part_count = 3'd3;
            6'b110010: live_neighbors_part_count = 3'd3;
            6'b110011: live_neighbors_part_count = 3'd4;
            6'b110100: live_neighbors_part_count = 3'd3;
            6'b110101: live_neighbors_part_count = 3'd4;
            6'b110110: live_neighbors_part_count = 3'd4;
            6'b110111: live_neighbors_part_count = 3'd5;
            6'b111000: live_neighbors_part_count = 3'd3;
            6'b111001: live_neighbors_part_count = 3'd4;
            6'b111010: live_neighbors_part_count = 3'd4;
            6'b111011: live_neighbors_part_count = 3'd5;
            6'b111100: live_neighbors_part_count = 3'd4;
            6'b111101: live_neighbors_part_count = 3'd5;
            6'b111110: live_neighbors_part_count = 3'd5;
            6'b111111: live_neighbors_part_count = 3'd6;
        endcase
    end

    reg out;

    always @(*) begin
        case ({live_neighbors_part_count, neighbors[1:0], cell_cur})
            // 1. Any live cell with two or three live neighbours survives.
            6'b000_11_1: out = 1'b1;
            6'b001_10_1: out = 1'b1;
            6'b001_01_1: out = 1'b1;
            6'b010_00_1: out = 1'b1;
            6'b001_11_1: out = 1'b1;
            6'b010_10_1: out = 1'b1;
            6'b010_01_1: out = 1'b1;
            6'b011_00_1: out = 1'b1;
            // 2. Any dead cell with three live neighbours becomes a live cell.
            6'b001_11_0: out = 1'b1;
            6'b010_10_0: out = 1'b1;
            6'b010_01_0: out = 1'b1;
            6'b011_00_0: out = 1'b1;
            // 3. All other live cells die in the next generation. Similarly, all other dead cells stay dead.
            default: out = 1'b0;
        endcase
    end

    assign cell_new = out;

endmodule

