
`include "command.vh"

module cmd_gen(
    input clk,
    input reset,

    input [3:0] buttons,

    output [2:0] cmd,
    output [31:0] cmd_arg0,
    output cmd_valid
);

    wire [3:0] buttons_debounced;

    switch_debouncer #(
        .WIDTH(4),
        .SAMPLES_COUNT(5),
        .TICKS_PER_SAMPLE(1_000_000)
    ) subject (
        .in(buttons),
        .out(buttons_debounced),
        .clk(clk),
        .reset_n(~reset)
    );

    wire [3:0] buttons_pulsed;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin: pulser
            reg r0;
            reg r1;
            always @(posedge clk) begin
                r0 <= buttons_debounced[i];
                r1 <= r0;
            end
            assign buttons_pulsed[i] = r0 & ~r1;
        end
    endgenerate


    reg [2:0] cmd_reg;
    reg [31:0] cmd_arg0_reg;
    reg cmd_valid_reg;

    always @(*) begin
        cmd_reg = 3'bxxx;
        cmd_arg0_reg = 32'b0;
        cmd_valid_reg = 1'b0;
        case (buttons_pulsed)
            4'b0001: begin
                cmd_reg = `CMD_IDLE;
                cmd_valid_reg = 1'b1;
            end
            4'b0010: begin
                cmd_reg = `CMD_ADVANCE;
                cmd_arg0_reg = 32'h0000_0001;
                cmd_valid_reg = 1'b1;
            end
            4'b0100: begin
                cmd_reg = `CMD_READ_CELL;
                cmd_valid_reg = 1'b1;
            end
            4'b1000: begin
                cmd_reg = `CMD_SEED;
                cmd_arg0_reg = 32'hcafebabe;
                cmd_valid_reg = 1'b1;
            end
            default: begin
            end
        endcase
    end

    assign cmd = cmd_reg;
    assign cmd_arg0 = cmd_arg0_reg;
    assign cmd_valid_reg = cmd_valid;

endmodule

