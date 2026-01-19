
module seven_seg_temp (
    input  wire        clk,
    input  wire signed [31:0] temp_x100,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);

    reg [7:0] temp_int;
    reg [3:0] tens, ones;
    reg [1:0] scan;

    always @(*) begin
        if (temp_x100 < 0)
            temp_int = 0;
        else
            temp_int = temp_x100 / 100;

        tens = temp_int / 10;
        ones = temp_int % 10;
    end

    always @(posedge clk)
        scan <= scan + 1;

    always @(*) begin
        case (scan)
            2'd0: begin an = 4'b1110; seg = decode(ones); end
            2'd1: begin an = 4'b1101; seg = decode(tens); end
            default: begin an = 4'b1111; seg = 7'b1111111; end
        endcase
    end

    function [6:0] decode;
        input [3:0] d;
        case (d)
            0: decode = 7'b1000000;
            1: decode = 7'b1111001;
            2: decode = 7'b0100100;
            3: decode = 7'b0110000;
            4: decode = 7'b0011001;
            5: decode = 7'b0010010;
            6: decode = 7'b0000010;
            7: decode = 7'b1111000;
            8: decode = 7'b0000000;
            9: decode = 7'b0010000;
            default: decode = 7'b1111111;
        endcase
    endfunction
endmodule
