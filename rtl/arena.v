
module arena #(
    parameter WIDTH = 10,
    parameter HEIGHT = 10
)(
    input a_clk,
    input [9:0] a_row,
    output [WIDTH-1:0] a_columns_out,

    input b_clk,
    input [9:0] b_row,
    input [WIDTH-1:0] b_columns_in,
    output [WIDTH-1:0] b_columns_out,
    input b_write
);

    reg [WIDTH-1:0] RAM[0:HEIGHT-1];

    reg [WIDTH-1:0] a_columns_out_reg;
    reg [WIDTH-1:0] b_columns_out_reg;

    assign a_columns_out = a_columns_out_reg;
    assign b_columns_out = b_columns_out_reg;

    always @(posedge a_clk) begin
        a_columns_out_reg <= RAM[a_row];
    end

    always @(posedge b_clk) begin
        b_columns_out_reg <= RAM[b_row];
        if (b_write) begin
            RAM[b_row] <= b_columns_in;
        end
    end

`ifdef __ICARUS__
    integer i;
    initial begin
        for (i = 0; i < HEIGHT; i = i + 1) begin
            $dumpvars(0, RAM[i]);
        end
    end
`endif

endmodule

