`timescale 1ns / 1ps
// twiddle_rom.v
// Q2.22 fixed-point twiddle factor ROM for 32-point DIT FFT.
// Stores W_32^k = cos(2*pi*k/32) - j*sin(2*pi*k/32), for k = 0..15
// Output packed as {real[23:0], imag[23:0]} = 48 bits total.

module twiddle_rom (
    input  wire [3:0]  addr,
    output reg  [47:0] twiddle_out
);

    always @(*) begin
        case (addr)
            0:  twiddle_out = {24'h400000, 24'h000000};  //  1.00000000 - j0.00000000
            1:  twiddle_out = {24'h3EC530, 24'hF383A4};  //  0.98078528 - j0.19509032
            2:  twiddle_out = {24'h3B20D8, 24'hE7821D};  //  0.92387953 - j0.38268343
            3:  twiddle_out = {24'h3536CC, 24'hDC718A};  //  0.83146961 - j0.55557023
            4:  twiddle_out = {24'h2D413D, 24'hD2BEC3};  //  0.70710678 - j0.70710678
            5:  twiddle_out = {24'h238E76, 24'hCAC934};  //  0.55557023 - j0.83146961
            6:  twiddle_out = {24'h187DE3, 24'hC4DF28};  //  0.38268343 - j0.92387953
            7:  twiddle_out = {24'h0C7C5C, 24'hC13AD0};  //  0.19509032 - j0.98078528
            8:  twiddle_out = {24'h000000, 24'hC00000};  //  0.00000000 - j1.00000000
            9:  twiddle_out = {24'hF383A4, 24'hC13AD0};  // -0.19509032 - j0.98078528
            10: twiddle_out = {24'hE7821D, 24'hC4DF28};  // -0.38268343 - j0.92387953
            11: twiddle_out = {24'hDC718A, 24'hCAC934};  // -0.55557023 - j0.83146961
            12: twiddle_out = {24'hD2BEC3, 24'hD2BEC3};  // -0.70710678 - j0.70710678
            13: twiddle_out = {24'hCAC934, 24'hDC718A};  // -0.83146961 - j0.55557023
            14: twiddle_out = {24'hC4DF28, 24'hE7821D};  // -0.92387953 - j0.38268343
            15: twiddle_out = {24'hC13AD0, 24'hF383A4};  // -0.98078528 - j0.19509032
            default: twiddle_out = 48'h0000_0000_0000;
        endcase
    end

endmodule