
module mux_4x1 #(
    parameter WIDTH = 10
)(
    input [1:0] select,

    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input [WIDTH-1:0] in2,
    input [WIDTH-1:0] in3,

    output [WIDTH-1:0] out
);
    reg [WIDTH-1:0] out_reg;

    always @(*) begin
        case (select)
            2'b00: out_reg = in0;
            2'b01: out_reg = in1;
            2'b10: out_reg = in2;
            2'b11: out_reg = in3;
        endcase
    end

    assign out = out_reg;

endmodule

