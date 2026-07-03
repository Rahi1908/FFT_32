`timescale 1ns / 1ps

module q_narrow (
    // Q2.22 (24-bit) in -> Q2.14 (16-bit) out. Rounds to nearest (not
    // truncate) and saturates if the accumulated value exceeds Q2.14's range.
    input  wire signed [23:0] in_q22,
    output reg  signed [15:0] out_q14,
    output reg               overflow
);
    localparam FRAC_DIFF = 8;   // 22 - 14

    // round-to-nearest: add half the divisor before shifting (same trick
    // used in fixed_multiplier)
    wire signed [23:0] rounded  = in_q22 + (24'sd1 <<< (FRAC_DIFF-1));
    wire signed [23:0] shifted  = rounded >>> FRAC_DIFF;   // now Q2.14-scaled, still 24 bits wide

    localparam signed [15:0] MAX_VAL = 16'sh7FFF;
    localparam signed [15:0] MIN_VAL = 16'sh8000;

    wire is_overflow = (shifted > $signed({{8{1'b0}}, MAX_VAL})) ||
                        (shifted < $signed({{8{1'b1}}, MIN_VAL}));

    always @(*) begin
        if (shifted > $signed({{8{1'b0}}, MAX_VAL})) begin
            out_q14  = MAX_VAL;
            overflow = 1'b1;
        end else if (shifted < $signed({{8{1'b1}}, MIN_VAL})) begin
            out_q14  = MIN_VAL;
            overflow = 1'b1;
        end else begin
            out_q14  = shifted[15:0];
            overflow = 1'b0;
        end
    end
endmodule