
module agent_selector (
    input clk,
    input reset,

    input [1:0] agent_select_in,
    output [1:0] agent_select_out,

    output agent_0_start,
    output agent_1_start,
    output agent_2_start,
    output agent_3_start,

    input agent_0_ready,
    input agent_1_ready,
    input agent_2_ready,
    input agent_3_ready,
    
    input start,
    output ready
);
    reg [1:0] selected_agent;
    wire [1:0] selected_agent_next;
    wire can_start;

    assign ready = agent_0_ready & agent_1_ready & agent_2_ready & agent_3_ready;
    assign can_start = ready & start;
    assign selected_agent_next = can_start ? agent_select_in : selected_agent;

    assign agent_0_start = can_start && agent_select_in == 2'b00;
    assign agent_1_start = can_start && agent_select_in == 2'b01;
    assign agent_2_start = can_start && agent_select_in == 2'b10;
    assign agent_3_start = can_start && agent_select_in == 2'b11;

    assign agent_select_out = selected_agent;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            selected_agent <= 2'b00;
        end
        else begin
            selected_agent <= selected_agent_next;
        end
    end

endmodule

