`timescale 1ns / 1ps

module fixed_multiplier #(
    parameter WIDTH = 16,
    parameter FRAC  = 14          
)(
    input  wire                      clk,
    input  wire                      rst,
    input  wire                      valid_in,
    input  wire signed [WIDTH-1:0]   a,
    input  wire signed [WIDTH-1:0]   b,
    output reg  signed [WIDTH-1:0]   result,
    output reg                       overflow,
    output reg                       valid_out
);

    
    wire signed [2*WIDTH-1:0] product_full = a * b;

    // shift right by FRAC to bring back to Q2.22, with round-to-nearest
    wire signed [2*WIDTH-1:0] product_rounded = product_full + (1 <<< (FRAC-1));
    wire signed [2*WIDTH-FRAC-1:0] product_scaled = product_rounded >>> FRAC;

   localparam signed [WIDTH-1:0] MAX_VAL = {1'b0, {(WIDTH-1){1'b1}}};
   localparam signed [WIDTH-1:0] MIN_VAL = {1'b1, {(WIDTH-1){1'b0}}};

    wire is_overflow = (product_scaled > $signed({{(WIDTH-FRAC+2){1'b0}}, MAX_VAL})) ||
                        (product_scaled < $signed({{(WIDTH-FRAC+2){1'b1}}, MIN_VAL}));

    wire signed [WIDTH-1:0] product_clamped =
                        (product_scaled > $signed({{(WIDTH-FRAC+2){1'b0}}, MAX_VAL})) ? MAX_VAL :
                        (product_scaled < $signed({{(WIDTH-FRAC+2){1'b1}}, MIN_VAL})) ? MIN_VAL :
                        product_scaled[WIDTH-1:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result    <= {WIDTH{1'b0}};
            overflow  <= 1'b0;
            valid_out <= 1'b0;
        end else begin
            result    <= product_clamped;
            overflow  <= is_overflow;
            valid_out <= valid_in;
        end
    end

endmodule