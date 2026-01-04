`timescale 1ns / 1ps

module temp_tracker_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    output wire        uart_tx
);

    // ============================
    // XADC Interface
    // ============================
    wire [15:0] xadc_do;
    wire        xadc_drdy;

    xadc_wiz_0 xadc_inst (
        .dclk_in   (clk),
        .reset_in  (rst),
        .den_in    (1'b1),
        .daddr_in  (7'h00),   // Temperature channel
        .do_out    (xadc_do),
        .drdy_out  (xadc_drdy)
    );

    // ============================
    // Temperature Register
    // ============================
    reg [15:0] temp_raw;

    always @(posedge clk) begin
        if (rst)
            temp_raw <= 16'd0;
        else if (xadc_drdy)
            temp_raw <= xadc_do;
    end

    // ============================
    // Raw ? Celsius (Integer)
    // Temp ? (raw * 504 >> 16) - 273
    // ============================
    wire signed [15:0] temp_c;

    assign temp_c = ((temp_raw * 16'd504) >> 16) - 16'd273;

    // ============================
    // UART Transmission
    // ============================
    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD(115200)
    ) uart_inst (
        .clk   (clk),
        .rst   (rst),
        .send  (enable),
        .data  (temp_c),
        .tx    (uart_tx)
    );

endmodule
