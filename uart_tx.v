module uart_temp_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 9600
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire signed [31:0] temp_x100,
    output reg         tx,
    output reg         busy
);

    localparam BAUD_DIV = CLK_FREQ / BAUD;

    // ---------------- Baud generator ----------------
    reg [13:0] baud_cnt;
    reg        baud_tick;

    always @(posedge clk) begin
        if (baud_cnt == BAUD_DIV-1) begin
            baud_cnt  <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt  <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end

    // ---------------- UART registers ----------------
    reg [3:0]  state;
    reg [7:0]  shifter;
    reg [2:0]  bit_cnt;
    reg [3:0]  char_idx;

    // ---------------- Temperature pipeline ----------------
    reg signed [31:0] temp_val;
    reg        sign;
    reg [31:0] temp_abs;
    reg [3:0]  digits [0:4];  // H, T, O, f1, f2
    reg [2:0]  digit_step;

    function [7:0] ascii;
        input [3:0] d;
        ascii = d + 8'd48;
    endfunction

    // ---------------- Main FSM ----------------
    always @(posedge clk) begin
        if (rst) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            state     <= 0;
            char_idx  <= 0;
            bit_cnt   <= 0;
            digit_step<= 0;
        end

        // ----------- Start transaction -----------
        else if (start && !busy) begin
            temp_val   <= temp_x100;
            sign       <= (temp_x100 < 0);
            temp_abs   <= (temp_x100 < 0) ? -temp_x100 : temp_x100;
            digit_step <= 0;
            busy       <= 1;
            state      <= 10;   // go to digit extraction
        end

        // ----------- Digit extraction (1 digit / cycle) -----------
        else if (state == 10) begin
            case (digit_step)
                0: begin digits[0] <= (temp_abs / 10000); temp_abs <= temp_abs % 10000; end
                1: begin digits[1] <= (temp_abs / 1000 ); temp_abs <= temp_abs % 1000;  end
                2: begin digits[2] <= (temp_abs / 100  ); temp_abs <= temp_abs % 100;   end
                3: begin digits[3] <= (temp_abs / 10   ); temp_abs <= temp_abs % 10;    end
                4: begin digits[4] <=  temp_abs;         state    <= 1; char_idx <= 0; end
            endcase
            digit_step <= digit_step + 1;
        end

        // ----------- UART FSM (baud-tick only) -----------
        else if (busy && baud_tick) begin
            case (state)

                1: begin
                    case (char_idx)
                        0: shifter <= sign ? "-" : "+";
                        1: shifter <= ascii(digits[0]);
                        2: shifter <= ascii(digits[1]);
                        3: shifter <= ascii(digits[2]);
                        4: shifter <= ".";
                        5: shifter <= ascii(digits[3]);
                        6: shifter <= ascii(digits[4]);
                        7: shifter <= 8'h0D;
                        8: shifter <= 8'h0A;
                    endcase
                    tx      <= 0;
                    bit_cnt <= 0;
                    state   <= 2;
                end

                2: begin
                    tx <= shifter[bit_cnt];
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7)
                        state <= 3;
                end

                3: begin
                    tx    <= 1;
                    state <= 4;
                end

                4: begin
                    char_idx <= char_idx + 1;
                    if (char_idx == 8) begin
                        busy  <= 0;
                        state <= 0;
                    end else begin
                        state <= 1;
                    end
                end
            endcase
        end
    end
endmodule
