`timescale 1ns/1ps

module tb_uart_rx;

    localparam integer CLKS_PER_BIT = 16;
    localparam integer CLK_PERIOD   = 10;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg rx_serial = 1'b1;
    wire [7:0] rx_data;
    wire rx_data_valid;

    integer errors = 0;
    reg valid_seen = 1'b0;

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),
        .rx_data(rx_data),
        .rx_data_valid(rx_data_valid)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    always @(posedge clk) begin
        if (rx_data_valid)
            valid_seen <= 1'b1;
    end

    // Hold each serial bit for exactly CLKS_PER_BIT clock cycles.
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            valid_seen = 1'b0;
            rx_serial = 1'b0; // Start bit
            repeat (CLKS_PER_BIT) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data[i]; // LSB first
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            rx_serial = 1'b1; // Stop bit
            repeat (CLKS_PER_BIT) @(posedge clk);
            repeat (3) @(posedge clk);
        end
    endtask

    task check_byte;
        input [7:0] expected;
        begin
            if (rx_data_valid !== 1'b1) begin
                $display("FAIL: rx_data_valid was not asserted");
                errors = errors + 1;
            end
            if (rx_data !== expected) begin
                $display("FAIL: expected 0x%02h, received 0x%02h", expected, rx_data);
                errors = errors + 1;
            end else begin
                $display("PASS: received 0x%02h", rx_data);
            end
        end
    endtask

    // Check valid pulse and data after each frame.
    task receive_and_check;
        input [7:0] value;
        begin
            send_uart_byte(value);
            // The valid pulse occurs at the end of the stop bit; inspect data.
            if (valid_seen !== 1'b1) begin
                $display("FAIL: rx_data_valid pulse was not detected");
                errors = errors + 1;
            end
            if (rx_data !== value) begin
                $display("FAIL: expected 0x%02h, received 0x%02h", value, rx_data);
                errors = errors + 1;
            end else begin
                $display("PASS: received 0x%02h", rx_data);
            end
        end
    endtask

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        receive_and_check(8'hA5);
        receive_and_check(8'h3C);
        receive_and_check(8'h00);
        receive_and_check(8'hFF);

        if (errors == 0)
            $display("ALL UART RECEIVER TESTS PASSED");
        else
            $display("UART RECEIVER TESTS FAILED: %0d error(s)", errors);

        #50;
        $finish;
    end

endmodule
