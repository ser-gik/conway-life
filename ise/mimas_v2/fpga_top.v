
module fpga_top (
    input CLK_100MHz,

    input UART_TX,
    output UART_RX,

    input [5:0] Switch,

    output [7:0] LED,
    
    output [7:0] SevenSegment,
    output [2:0] SevenSegmentEnable,

    output HSync,
    output VSync,
    output [2:0] Red,
    output [2:0] Green,
    output [2:1] Blue,
);

    // Turn off unneeded LEDs
    assign LED = 8'b0;
    assign SevenSegment = 8'b0;
    assign SevenSegmentEnable = 3'b0;



endmodule

