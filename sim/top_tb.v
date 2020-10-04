
`include "command.vh"

`timescale 1ns/100ps

module top_tb;
    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset;
    reg [2:0] cmd;
    reg [31:0] cmd_arg0;
    reg cmd_valid;
    wire cmd_ready;
    wire [31:0] cmd_res;

    top #(
        .ARENA_WIDTH(36),
        .ARENA_HEIGHT(10)
    ) uut (
        .clk(clk),
        .reset(reset),

        .arena_rd_clk(1'b0),
        .arena_rd_column(10'b0),
        .arena_rd_row(10'b0),
        .arena_rd_data_out(),

        .cmd(cmd),
        .cmd_arg0(cmd_arg0),
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .cmd_res(cmd_res)
    );


    task issue_command;
        input [2:0] command;
        input [31:0] arg0;
        begin
            cmd = command;
            cmd_arg0 = arg0;
            cmd_valid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            cmd_valid = 1'b0;
            wait(cmd_ready == 1'b1);
            @(posedge clk);
            @(negedge clk);
        end
    endtask


    initial begin
        reset = 1'b1;
        cmd_valid = 1'b0;
        repeat(2) @(posedge clk);
        reset = 1'b0;
        repeat(2) @(posedge clk);

        issue_command(`CMD_IDLE, 32'h0000_0000);
        issue_command(`CMD_SEED, 32'hcafe_babe);
        issue_command(`CMD_SEED, 32'hbaad_f00d);
        issue_command(`CMD_ADVANCE, 32'h0000_0002);
        issue_command(`CMD_READ_CELL, 32'b000000000000_0000000010_0000000001);
        issue_command(`CMD_READ_CELL, 32'b000000000000_0000000010_0000000010);
        issue_command(`CMD_READ_CELL, 32'b000000000000_0000000010_0000000011);
        issue_command(`CMD_READ_CELL, 32'b000000000000_0000000010_0000000100);
        issue_command(`CMD_READ_CELL, 32'b000000000000_0000000010_0000000101);
        issue_command(`CMD_READ_CELL, 32'b000000000000_0000000010_0000000110);

        $finish;
    end

endmodule

