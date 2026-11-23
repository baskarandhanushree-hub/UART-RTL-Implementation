`timescale 1ns/1ps

// Parameterized UART receiver: 8 data bits, no parity, 1 stop bit (8-N-1).
// RX is synchronized to clk before being sampled.
module uart_rx #(
    parameter integer CLKS_PER_BIT = 434  // 50 MHz / 115200 baud, rounded
)(
    input  wire       clk,
    input  wire       rst_n,       // Active-low asynchronous reset
    input  wire       rx_serial,
    output reg [7:0]  rx_data,
    output reg        rx_data_valid
);

    localparam [1:0] IDLE      = 2'd0;
    localparam [1:0] START_BIT = 2'd1;
    localparam [1:0] DATA_BITS = 2'd2;
    localparam [1:0] STOP_BIT  = 2'd3;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;

    // Two-flop synchronizer reduces metastability risk on asynchronous RX.
    reg rx_meta;
    reg rx_sync;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx_serial;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            clk_count     <= 16'd0;
            bit_index     <= 3'd0;
            rx_data       <= 8'd0;
            rx_data_valid <= 1'b0;
        end else begin
            // A one-clock pulse is generated only when a full frame is received.
            rx_data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (rx_sync == 1'b0)
                        state <= START_BIT;
                end

                START_BIT: begin
                    // Check the middle of the start bit.
                    if (clk_count == (CLKS_PER_BIT/2 - 1)) begin
                        if (rx_sync == 1'b0) begin
                            clk_count <= 16'd0;
                            state <= DATA_BITS;
                        end else begin
                            state <= IDLE; // False start
                            clk_count <= 16'd0;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA_BITS: begin
                    if (clk_count == (CLKS_PER_BIT - 1)) begin
                        clk_count <= 16'd0;
                        rx_data[bit_index] <= rx_sync; // UART transmits LSB first
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP_BIT: begin
                    if (clk_count == (CLKS_PER_BIT - 1)) begin
                        clk_count <= 16'd0;
                        state <= IDLE;
                        if (rx_sync == 1'b1)
                            rx_data_valid <= 1'b1;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                    clk_count <= 16'd0;
                end
            endcase
        end
    end

endmodule
