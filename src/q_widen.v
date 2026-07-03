`timescale 1ns / 1ps

module q_widen (
    // Q2.14 (16-bit) in -> Q2.22 (24-bit) out. Exact, no rounding needed
  
    input  wire signed [15:0] in_q14,
    output wire signed [23:0] out_q22
);
    // sign-extend 16 -> 24 bits, then shift left by (22-14)=8 to move the
    // binary point from 14 fractional bits to 22 fractional bits
    assign out_q22 = {{8{in_q14[15]}}, in_q14} <<< 8;
endmodule