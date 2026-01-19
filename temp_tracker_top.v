
module temp_tracker_top (
    input  clk,
    input  rst,
    output tx,
    output [6:0] seg,
    output [3:0] an
);

    /* =====================================================
       1. XADC INTERFACE (UG480 compliant)
       ===================================================== */

    wire [15:0] xadc_raw;
    wire [11:0] adc_code;

    assign adc_code = xadc_raw[15:4];

    xadc_wiz_0 XADC (
        .dclk_in   (clk),
        .den_in    (1'b1),
        .daddr_in  (7'h00),  
        .do_out    (xadc_raw),
        .drdy_out  (),
        .reset_in  (rst)
    );

    /* =====================================================
       2. TEMPERATURE CONVERSION (°C × 100)
       UG480: T = (ADC × 503.975 / 4096) - 273.15
       ===================================================== */

    reg signed [31:0] temp_x100;

    always @(posedge clk) begin
        temp_x100 <= ((adc_code * 50397) >>> 12) - 27315;
    end

    /* =====================================================
       3. UART TRANSMITTER 
       ===================================================== */

    wire uart_busy;
    reg  uart_start;

    reg [26:0] tx_timer;
    always @(posedge clk) begin
        if (rst) begin
            tx_timer  <= 0;
            uart_start <= 1'b0;
        end else if (tx_timer == 27'd100_000_000) begin
            tx_timer  <= 0;
            uart_start <= 1'b1;
        end else begin
            tx_timer  <= tx_timer + 1;
            uart_start <= 1'b0;
        end
    end

    uart_temp_tx UART_TX (
        .clk       (clk),
        .rst       (rst),
        .start     (uart_start & ~uart_busy),
        .temp_x100 (temp_x100),
        .tx        (tx),
        .busy      (uart_busy)
    );

    /* =====================================================
       4. SEVEN-SEGMENT DISPLAY (integer °C)
       ===================================================== */

    seven_seg_temp SEVENSEG (
        .clk       (clk),
        .temp_x100 (temp_x100),
        .seg       (seg),
        .an        (an)
    );

endmodule
