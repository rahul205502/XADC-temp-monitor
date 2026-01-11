module top_temp_7seg (
    input  wire        clk,        // 100 MHz
    input  wire        rst,        // active-high reset
    input  wire [7:0]  temp_c,    // temperature in °C (integer)
    output reg  [6:0]  seg,        // segments a-g (active low)
    output reg  [3:0]  an          // digit enable (active low)
);

    // ============================================================
    // Refresh clock for multiplexing (~1 kHz per digit)
    // ============================================================
    reg [16:0] refresh_cnt;
    reg [1:0]  digit_sel;

    always @(posedge clk) begin
        if (rst) begin
            refresh_cnt <= 0;
            digit_sel   <= 0;
        end else begin
            refresh_cnt <= refresh_cnt + 1;
            if (refresh_cnt == 17'd99999) begin
                refresh_cnt <= 0;
                digit_sel   <= digit_sel + 1;
            end
        end
    end

    // ============================================================
    // Binary ? BCD conversion (0-199 °C)
    // ============================================================
    reg [3:0] hundreds, tens, ones;

    always @(*) begin
        hundreds = temp_c / 100;
        tens     = (temp_c % 100) / 10;
        ones     = temp_c % 10;
    end

    // ============================================================
    // Digit multiplexer
    // ============================================================
    reg [3:0] digit;

    always @(*) begin
        case (digit_sel)
            2'd0: begin an = 4'b1110; digit = ones;     end
            2'd1: begin an = 4'b1101; digit = tens;     end
            2'd2: begin an = 4'b1011; digit = hundreds; end
            2'd3: begin an = 4'b0111; digit = 4'hF;     end // blank
            default: begin an = 4'b1111; digit = 4'hF; end
        endcase
    end

    // ============================================================
    // Seven-segment decoder (active-low, common-anode)
    // ============================================================
    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // blank
        endcase
    end

endmodule
