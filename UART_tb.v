`timescale 1ns / 1ns  
`include "UART.v"

module UART_tb;

reg A;
wire B;

hello uut(A,B);

initial begin
     $dumpfile("test.vcd");
     $dumpvars(0, UART_tb);

     A=0;
     #20;

     A=1;
     #20;

     A=0;
     #20;

     $display("Test complete");

end

endmodule