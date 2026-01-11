//module uart_tx #(
//    parameter CLK_FREQ = 100_000_000,
//    parameter BAUD     = 115200
//)(
//    input  wire        clk,
//    input  wire        rst,
//    input  wire        en,
//    input  wire        send,
//    input  wire signed [11:0] data,
//    output reg         tx
//);

//    // ============================
//    // Baud generator
//    // ============================
//    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

//    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;
//    reg baud_tick;

//    always @(posedge clk) begin
//        if (!en) begin
//            baud_cnt  <= 0;
//            baud_tick <= 0;
//        end else if (baud_cnt == BAUD_DIV-1) begin
//            baud_cnt  <= 0;
//            baud_tick <= 1;
//        end else begin
//            baud_cnt  <= baud_cnt + 1;
//            baud_tick <= 0;
//        end
//    end

//    // ============================
//    // UART FSM
//    // ============================
//    localparam IDLE  = 0,
//               START = 1,
//               DATA  = 2,
//               STOP  = 3;

//    reg [1:0] state;
//    reg [3:0] bit_cnt;
//    reg [2:0] msg_idx;
//    reg [7:0] tx_byte;

//    reg [11:0] abs_temp;

//    // Message buffer: "T=XYZC\r\n"
//    reg [7:0] msg [0:7];

//    // ============================
//    // UART transmitter
//    // ============================
//    always @(posedge clk) begin
//        if (!en || rst) begin
//            state   <= IDLE;
//            tx      <= 1'b1;
//            bit_cnt <= 0;
//            msg_idx <= 0;
//        end else if (baud_tick) begin
//            case (state)

//                // ----------------------------
//                IDLE: begin
//                    tx <= 1'b1;
//                    if (send) begin
//                        abs_temp <= (data < 0) ? -data : data;

//                        msg[0] <= "T";
//                        msg[1] <= "=";
//                        msg[2] <= (abs_temp / 100) + 8'd48;
//                        msg[3] <= ((abs_temp / 10) % 10) + 8'd48;
//                        msg[4] <= (abs_temp % 10) + 8'd48;
//                        msg[5] <= "C";
//                        msg[6] <= 8'h0D;
//                        msg[7] <= 8'h0A;

//                        msg_idx <= 0;
//                        tx_byte <= msg[0];
//                        state   <= START;
//                    end
//                end

//                // ----------------------------
//                START: begin
//                    tx      <= 1'b0;   // Start bit
//                    bit_cnt <= 0;
//                    state   <= DATA;
//                end

//                // ----------------------------
//                DATA: begin
//                    tx <= tx_byte[bit_cnt];
//                    if (bit_cnt == 7)
//                        state <= STOP;
//                    else
//                        bit_cnt <= bit_cnt + 1;
//                end

//                // ----------------------------
//                STOP: begin
//                    tx <= 1'b1;  // Stop bit
//                    if (msg_idx == 7) begin
//                        state <= IDLE;
//                    end else begin
//                        msg_idx <= msg_idx + 1;
//                        tx_byte <= msg[msg_idx + 1];
//                        state   <= START;
//                    end
//                end

//            endcase
//        end
//    end

//endmodule


//module uart_tx #(
//    parameter CLK_FREQ = 100_000_000,
//    parameter BAUD     = 115200
//)(
//    input  wire        clk,
//    input  wire        rst,
//    input  wire        en,
//    input  wire        send,
//    input  wire [15:0] data,   // temperature value
//    output reg         tx
//);

//    // ============================
//    // Baud generator
//    // ============================
//    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

//    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;
//    reg baud_tick;

//    always @(posedge clk) begin
//        if (!en) begin
//            baud_cnt  <= 0;
//            baud_tick <= 0;
//        end else if (baud_cnt == BAUD_DIV-1) begin
//            baud_cnt  <= 0;
//            baud_tick <= 1;
//        end else begin
//            baud_cnt  <= baud_cnt + 1;
//            baud_tick <= 0;
//        end
//    end

//    // ============================
//    // UART FSM
//    // ============================
//    localparam IDLE  = 0,
//               START = 1,
//               DATA  = 2,
//               STOP  = 3;

//    reg [1:0]  state;
//    reg [4:0]  bit_cnt;     // counts 0-15
//    reg [15:0] shift_reg;

//    always @(posedge clk) begin
//        if (!en || rst) begin
//            state   <= IDLE;
//            tx      <= 1'b1;
//            bit_cnt <= 0;
//        end else if (baud_tick) begin
//            case (state)

//                IDLE: begin
//                    tx <= 1'b1;
//                    if (send) begin
//                        shift_reg <= data;
//                        bit_cnt   <= 0;
//                        state     <= START;
//                    end
//                end

//                START: begin
//                    tx    <= 1'b0;   // start bit
//                    state <= DATA;
//                end

//                DATA: begin
//                    tx <= shift_reg[bit_cnt];
//                    if (bit_cnt == 16)
//                        state <= STOP;
//                    else
//                        bit_cnt <= bit_cnt + 1;
//                end

//                STOP: begin
//                    tx    <= 1'b1;   // stop bit
//                    state <= IDLE;
//                end

//            endcase
//        end
//    end

//endmodule

module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        send,
    input  wire [15:0] data,
    output reg         tx
);

    // ============================
    // Baud generator
    // ============================
    localparam integer BAUD_DIV = CLK_FREQ / BAUD;

    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;
    reg baud_tick;

    always @(posedge clk) begin
        if (!en) begin
            baud_cnt  <= 0;
            baud_tick <= 0;
        end else if (baud_cnt == BAUD_DIV-1) begin
            baud_cnt  <= 0;
            baud_tick <= 1;
        end else begin
            baud_cnt  <= baud_cnt + 1;
            baud_tick <= 0;
        end
    end

    // ============================
    // UART FSM
    // ============================
    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0]  state;
    reg [4:0]  bit_cnt;
    reg [15:0] shift_reg;

    always @(posedge clk) begin
        if (!en) begin
            // Hard gate: absolutely no output
            state   <= IDLE;
            tx      <= 1'b1;
            bit_cnt <= 0;
        end else if (rst) begin
            // Reset causes a single transmission of 16'h0000
            shift_reg <= 16'h0000;
            bit_cnt   <= 0;
            state     <= START;
        end else if (baud_tick) begin
            case (state)

                IDLE: begin
                    tx <= 1'b1;
                    if (send) begin
                        shift_reg <= data;
                        bit_cnt   <= 0;
                        state     <= START;
                    end
                end

                START: begin
                    tx    <= 1'b0;   // start bit
                    state <= DATA;
                end

                DATA: begin
                    tx <= shift_reg[bit_cnt];
                    if (bit_cnt == 15)
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt + 1;
                end

                STOP: begin
                    tx    <= 1'b1;   // stop bit
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
