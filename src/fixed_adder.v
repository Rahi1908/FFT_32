`timescale 1ns / 1ps

module fixed_adder #(
    parameter WIDTH = 16
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    valid_in,
    input  wire                    subtract,        // 1 = a - b, 0 = a + b
    input  wire signed [WIDTH-1:0] a,
    input  wire signed [WIDTH-1:0] b,
    output reg  signed [WIDTH-1:0] result,
    output reg                     overflow,
    output reg                     valid_out
);

    wire signed [WIDTH:0] b_signed   = subtract ? -b : b;   
    wire signed [WIDTH:0] sum_full   = a + b_signed;       

    localparam signed [WIDTH-1:0] MAX_VAL = {1'b0, {(WIDTH-1){1'b1}}};
    localparam signed [WIDTH-1:0] MIN_VAL = {1'b1, {(WIDTH-1){1'b0}}};
    
    wire is_overflow = (sum_full > $signed({1'b0, MAX_VAL})) ||
                        (sum_full < $signed({1'b1, MIN_VAL}));

    wire signed [WIDTH-1:0] sum_clamped = (sum_full > $signed({1'b0, MAX_VAL})) ? MAX_VAL :
                                           (sum_full < $signed({1'b1, MIN_VAL})) ? MIN_VAL :
                                           sum_full[WIDTH-1:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result    <= {WIDTH{1'b0}};
            overflow  <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            result    <= sum_clamped;
            overflow  <= is_overflow;
            valid_out <= valid_in;
        end
    end

endmodule