`timescale 1ns / 1ps

module addr_gen_lut (
    input  wire [2:0] stage_num,
    input  wire [3:0] bfly_num,
    output reg  [4:0] addr_a,
    output reg  [4:0] addr_b,
    output reg  [3:0] tw_addr
);

    always @(*) begin

        case (stage_num)

            0: begin
                case (bfly_num)
                    0: begin addr_a =  0; addr_b =  1; tw_addr =  0; end
                    1: begin addr_a =  2; addr_b =  3; tw_addr =  0; end
                    2: begin addr_a =  4; addr_b =  5; tw_addr =  0; end
                    3: begin addr_a =  6; addr_b =  7; tw_addr =  0; end
                    4: begin addr_a =  8; addr_b =  9; tw_addr =  0; end
                    5: begin addr_a = 10; addr_b = 11; tw_addr =  0; end
                    6: begin addr_a = 12; addr_b = 13; tw_addr =  0; end
                    7: begin addr_a = 14; addr_b = 15; tw_addr =  0; end
                    8: begin addr_a = 16; addr_b = 17; tw_addr =  0; end
                    9: begin addr_a = 18; addr_b = 19; tw_addr =  0; end
                    10: begin addr_a = 20; addr_b = 21; tw_addr =  0; end
                    11: begin addr_a = 22; addr_b = 23; tw_addr =  0; end
                    12: begin addr_a = 24; addr_b = 25; tw_addr =  0; end
                    13: begin addr_a = 26; addr_b = 27; tw_addr =  0; end
                    14: begin addr_a = 28; addr_b = 29; tw_addr =  0; end
                    15: begin addr_a = 30; addr_b = 31; tw_addr =  0; end
                endcase
            end

            1: begin
                case (bfly_num)
                    0: begin addr_a =  0; addr_b =  2; tw_addr =  0; end
                    1: begin addr_a =  1; addr_b =  3; tw_addr =  8; end
                    2: begin addr_a =  4; addr_b =  6; tw_addr =  0; end
                    3: begin addr_a =  5; addr_b =  7; tw_addr =  8; end
                    4: begin addr_a =  8; addr_b = 10; tw_addr =  0; end
                    5: begin addr_a =  9; addr_b = 11; tw_addr =  8; end
                    6: begin addr_a = 12; addr_b = 14; tw_addr =  0; end
                    7: begin addr_a = 13; addr_b = 15; tw_addr =  8; end
                    8: begin addr_a = 16; addr_b = 18; tw_addr =  0; end
                    9: begin addr_a = 17; addr_b = 19; tw_addr =  8; end
                    10: begin addr_a = 20; addr_b = 22; tw_addr =  0; end
                    11: begin addr_a = 21; addr_b = 23; tw_addr =  8; end
                    12: begin addr_a = 24; addr_b = 26; tw_addr =  0; end
                    13: begin addr_a = 25; addr_b = 27; tw_addr =  8; end
                    14: begin addr_a = 28; addr_b = 30; tw_addr =  0; end
                    15: begin addr_a = 29; addr_b = 31; tw_addr =  8; end
                endcase
            end

            2: begin
                case (bfly_num)
                    0: begin addr_a =  0; addr_b =  4; tw_addr =  0; end
                    1: begin addr_a =  1; addr_b =  5; tw_addr =  4; end
                    2: begin addr_a =  2; addr_b =  6; tw_addr =  8; end
                    3: begin addr_a =  3; addr_b =  7; tw_addr = 12; end
                    4: begin addr_a =  8; addr_b = 12; tw_addr =  0; end
                    5: begin addr_a =  9; addr_b = 13; tw_addr =  4; end
                    6: begin addr_a = 10; addr_b = 14; tw_addr =  8; end
                    7: begin addr_a = 11; addr_b = 15; tw_addr = 12; end
                    8: begin addr_a = 16; addr_b = 20; tw_addr =  0; end
                    9: begin addr_a = 17; addr_b = 21; tw_addr =  4; end
                    10: begin addr_a = 18; addr_b = 22; tw_addr =  8; end
                    11: begin addr_a = 19; addr_b = 23; tw_addr = 12; end
                    12: begin addr_a = 24; addr_b = 28; tw_addr =  0; end
                    13: begin addr_a = 25; addr_b = 29; tw_addr =  4; end
                    14: begin addr_a = 26; addr_b = 30; tw_addr =  8; end
                    15: begin addr_a = 27; addr_b = 31; tw_addr = 12; end
                endcase
            end

            3: begin
                case (bfly_num)
                    0: begin addr_a =  0; addr_b =  8; tw_addr =  0; end
                    1: begin addr_a =  1; addr_b =  9; tw_addr =  2; end
                    2: begin addr_a =  2; addr_b = 10; tw_addr =  4; end
                    3: begin addr_a =  3; addr_b = 11; tw_addr =  6; end
                    4: begin addr_a =  4; addr_b = 12; tw_addr =  8; end
                    5: begin addr_a =  5; addr_b = 13; tw_addr = 10; end
                    6: begin addr_a =  6; addr_b = 14; tw_addr = 12; end
                    7: begin addr_a =  7; addr_b = 15; tw_addr = 14; end
                    8: begin addr_a = 16; addr_b = 24; tw_addr =  0; end
                    9: begin addr_a = 17; addr_b = 25; tw_addr =  2; end
                    10: begin addr_a = 18; addr_b = 26; tw_addr =  4; end
                    11: begin addr_a = 19; addr_b = 27; tw_addr =  6; end
                    12: begin addr_a = 20; addr_b = 28; tw_addr =  8; end
                    13: begin addr_a = 21; addr_b = 29; tw_addr = 10; end
                    14: begin addr_a = 22; addr_b = 30; tw_addr = 12; end
                    15: begin addr_a = 23; addr_b = 31; tw_addr = 14; end
                endcase
            end

            4: begin
                case (bfly_num)
                    0: begin addr_a =  0; addr_b = 16; tw_addr =  0; end
                    1: begin addr_a =  1; addr_b = 17; tw_addr =  1; end
                    2: begin addr_a =  2; addr_b = 18; tw_addr =  2; end
                    3: begin addr_a =  3; addr_b = 19; tw_addr =  3; end
                    4: begin addr_a =  4; addr_b = 20; tw_addr =  4; end
                    5: begin addr_a =  5; addr_b = 21; tw_addr =  5; end
                    6: begin addr_a =  6; addr_b = 22; tw_addr =  6; end
                    7: begin addr_a =  7; addr_b = 23; tw_addr =  7; end
                    8: begin addr_a =  8; addr_b = 24; tw_addr =  8; end
                    9: begin addr_a =  9; addr_b = 25; tw_addr =  9; end
                    10: begin addr_a = 10; addr_b = 26; tw_addr = 10; end
                    11: begin addr_a = 11; addr_b = 27; tw_addr = 11; end
                    12: begin addr_a = 12; addr_b = 28; tw_addr = 12; end
                    13: begin addr_a = 13; addr_b = 29; tw_addr = 13; end
                    14: begin addr_a = 14; addr_b = 30; tw_addr = 14; end
                    15: begin addr_a = 15; addr_b = 31; tw_addr = 15; end
                endcase
            end

        endcase

    end

endmodule