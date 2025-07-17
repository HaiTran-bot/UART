`timescale 1ns / 1ps
`include "UART.v"

module UART_tx_tb;

    reg clk;
    reg rst_n;
    reg [7:0] data_in;
    reg start;
    wire txd;
    wire busy;

    UART_tx uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .start(start),
        .txd(txd),
        .busy(busy)
    );

    // 50 MHz clock = 20 ns period
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("UART_tx_tb.vcd");
        $dumpvars(0, UART_tx_tb);

        // Reset
        rst_n = 0;
        start = 0;
        data_in = 8'd0;
        #100;

        rst_n = 1;
        #20;

        // 0xA5
        data_in = 8'b10100101;
        start = 1;
        #8680;      //keep start to capture baud tick
        start = 0;

        wait (busy == 0);
        #1000;

        //0x3C
        data_in = 8'b00111100;
        start = 1;
        #8680;
        start = 0;

        wait (busy == 0);
        #1000;

        $finish;
    end

endmodule
