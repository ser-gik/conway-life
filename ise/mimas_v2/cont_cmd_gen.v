
`include "command.vh"

module cont_cmd_gen(
    input clk,
    input reset,

    input [6:0] switches,

    output [2:0] cmd,
    output [31:0] cmd_arg0,
    output cmd_valid
);
    localparam BASE_BIT = 25; 
    reg [31:0] timer;
    wire [31:0] timer_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer <= {32{1'b1}};
        end
        else begin
            timer <= timer_next;
        end
    end

    assign timer_next = timer + 1'b1;

    wire [6:0] pulses;

    genvar i;
    generate
        for (i = 0; i < 7; i = i + 1) begin: pulse
            assign pulses[i] = ~timer[BASE_BIT - 2 * i] & timer_next[BASE_BIT - 2 * i];
        end
    endgenerate

    assign cmd = `CMD_ADVANCE;
    assign cmd_arg0 = 32'b1;

    assign cmd_valid = switches[6] ? pulses[6] :
                       switches[5] ? pulses[5] :
                       switches[4] ? pulses[4] :
                       switches[3] ? pulses[3] :
                       switches[2] ? pulses[2] :
                       switches[1] ? pulses[1] :
                       switches[0] ? pulses[0] :
                       1'b0;

endmodule

