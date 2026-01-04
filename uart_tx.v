module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        send,
    input  wire signed [15:0] data,
    output reg         tx
);

    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

    reg [15:0] baud_cnt;
    reg        baud_tick;

    always @(posedge clk) begin
        if (!en) begin
            baud_cnt  <= 0;
            baud_tick <= 0;
        end else if (baud_cnt == BAUD_DIV - 1) begin
            baud_cnt  <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt  <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end

    // ============================
    // Temperature ? ASCII
    // ============================
    reg [7:0] msg [0:7];
    reg [3:0] idx;
    reg [3:0] state;
    reg [15:0] abs_temp;

    localparam IDLE  = 0,
               START = 1,
               DATA  = 2,
               STOP  = 3;

    // initial tx = 1'b1;

    always @(posedge clk) begin
        if (!en) begin
            state <= IDLE;
            idx   <= 0;
            tx    <= 1'b1;
        end else if (baud_tick) begin
            case (state)
                IDLE: begin
                    if (send) begin
                        abs_temp = (data < 0) ? -data : data;

                        msg[0] = "T";
                        msg[1] = "=";
                        msg[2] = (abs_temp / 100) + 8'd48;
                        msg[3] = ((abs_temp / 10) % 10) + 8'd48;
                        msg[4] = (abs_temp % 10) + 8'd48;
                        msg[5] = "C";
                        msg[6] = 8'h0D;
                        msg[7] = 8'h0A;

                        idx   <= 0;
                        state <= START;
                    end
                end

                START: begin
                    tx    <= 0;
                    state <= DATA;
                end

                DATA: begin
                    tx <= msg[idx][0];
                    msg[idx] <= msg[idx] >> 1;

                    if (&msg[idx][7:1]) begin
                        idx <= idx + 1;
                        state <= STOP;
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (idx == 7)
                        state <= IDLE;
                    else
                        state <= START;
                end
            endcase
        end
    end

endmodule
