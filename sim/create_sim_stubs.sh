#!/usr/bin/env sh

set -e

NAME=${1}

if [ -z ${NAME} ]
then
    echo Name is not specified
    exit 1
fi

echo Creating stubs for simulation \"${NAME}\"...

cat > ${NAME}_tb.v << EOM

\`timescale 1ns/100ps

module ${NAME}_tb;
    localparam CLK_PERIOD = 4;
    reg clk;
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    reg reset;
    initial begin
        reset = 1'b1;
        repeat(2) @(posedge clk);
        reset = 1'b0;


        \$finish;
    end


endmodule

EOM

touch ${NAME}_tb.icarus.gtkw
touch ${NAME}_tb.mentor.do

echo Done

