//implement transmitter only and its 8-bit
module UART_tx(
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire start,
    output reg txd, //or data out
    output reg busy //on when start til finish
);
    parameter SB_TICKS  = 16;            // tick to remain stop bit 16 cycle baud
    parameter CLK_FREQ  = 50000000;   //tan so mach thuong gap
    parameter BAUD_RATE = 115200;       //toc do baud thuong gap

    localparam DIV = CLK_FREQ / BAUD_RATE;

    reg [8:0] baud_cnt; //approx 434 so need 9 bit count
    reg        baud_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt  <= 0;
            baud_tick <= 0;
        end else if (baud_cnt == DIV - 1) begin 
            baud_cnt  <= 0; // reset
            baud_tick <= 1; 
        end else begin
            baud_cnt  <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end

    //state of transmit
    localparam IDLE      = 0;
    localparam START_BIT = 1;
    localparam DATA_BITS = 2; 
    localparam STOP_BITS = 3;

    reg [1:0]  state; 
    reg [2:0]  bit_idx; //need 3 bit to count 8 bit 
    reg [7:0]  shifter; //take data_in to make sure no data loss
    reg [3:0]  stop_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            txd      <= 1;
            busy     <= 0;
            bit_idx  <= 0;
            stop_cnt <= 0;
        end else if(baud_tick) begin
            case(state)
               IDLE: begin
                    txd <= 1;
                    busy <= 0;
                    if (start) begin
                        shifter <= data_in;
                        busy    <= 1;
                        state   <= START_BIT;
                    end
               end
               START_BIT: begin
                    txd    <= 0;
                    bit_idx <= 0;
                    state  <= DATA_BITS;
                end
                DATA_BITS: begin
                    txd <= shifter[bit_idx];
                    if (bit_idx == 7) begin
                        state <= STOP_BITS;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                end
                STOP_BITS: begin
                    txd <= 1;
                    if (stop_cnt == SB_TICKS - 1) begin
                        stop_cnt <= 0;
                        state    <= IDLE;
                        busy     <= 0;
                    end else begin
                        stop_cnt <= stop_cnt + 1;
                    end
                end
                default: state = IDLE;
            endcase 
        end
    end

endmodule
