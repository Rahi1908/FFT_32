`timescale 1ns / 1ps

module butterfly #(
    parameter WIDTH = 24,   // was 16
    parameter FRAC  = 22    // was 14
)(
    input  wire                      clk,
    input  wire                      rst,

    input  wire signed [WIDTH-1:0]   a_real,
    input  wire signed [WIDTH-1:0]   a_imag,
    input  wire signed [WIDTH-1:0]   b_real,
    input  wire signed [WIDTH-1:0]   b_imag,
    input  wire signed [WIDTH-1:0]   w_real,
    input  wire signed [WIDTH-1:0]   w_imag,

    output reg  signed [WIDTH-1:0]   x_real,
    output reg  signed [WIDTH-1:0]   x_imag,
    output reg  signed [WIDTH-1:0]   y_real,
    output reg  signed [WIDTH-1:0]   y_imag
);

    // ---- delay A by 2 cycles, to match B*W pipeline latency ----
    reg signed [WIDTH-1:0] a_real_d1, a_imag_d1;
    reg signed [WIDTH-1:0] a_real_d2, a_imag_d2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_real_d1 <= 0; a_imag_d1 <= 0;
            a_real_d2 <= 0; a_imag_d2 <= 0;
        end else begin
            a_real_d1 <= a_real;
            a_imag_d1 <= a_imag;
            a_real_d2 <= a_real_d1;
            a_imag_d2 <= a_imag_d1;
        end
    end

    // ---- Stage 1: complex multiply B * W ----
    wire signed [WIDTH-1:0] prod_br_wr, prod_bi_wi, prod_br_wi, prod_bi_wr;

    fixed_multiplier #(.WIDTH(WIDTH), .FRAC(FRAC)) mult_br_wr (
        .clk(clk), .rst(rst), .valid_in(1'b1),
        .a(b_real), .b(w_real), .result(prod_br_wr), .overflow(), .valid_out());
    fixed_multiplier #(.WIDTH(WIDTH), .FRAC(FRAC)) mult_bi_wi (
        .clk(clk), .rst(rst), .valid_in(1'b1),
        .a(b_imag), .b(w_imag), .result(prod_bi_wi), .overflow(), .valid_out());
    fixed_multiplier #(.WIDTH(WIDTH), .FRAC(FRAC)) mult_br_wi (
        .clk(clk), .rst(rst), .valid_in(1'b1),
        .a(b_real), .b(w_imag), .result(prod_br_wi), .overflow(), .valid_out());
    fixed_multiplier #(.WIDTH(WIDTH), .FRAC(FRAC)) mult_bi_wr (
        .clk(clk), .rst(rst), .valid_in(1'b1),
        .a(b_imag), .b(w_real), .result(prod_bi_wr), .overflow(), .valid_out());

    // ---- Stage 2: combine into real/imag parts of B*W ----
    wire signed [WIDTH-1:0] bw_real, bw_imag;

    fixed_adder #(.WIDTH(WIDTH)) add_bw_real (
        .clk(clk), .rst(rst), .valid_in(1'b1), .subtract(1'b1),
        .a(prod_br_wr), .b(prod_bi_wi), .result(bw_real), .overflow(), .valid_out());
    fixed_adder #(.WIDTH(WIDTH)) add_bw_imag (
        .clk(clk), .rst(rst), .valid_in(1'b1), .subtract(1'b0),
        .a(prod_br_wi), .b(prod_bi_wr), .result(bw_imag), .overflow(), .valid_out());

    // ---- Stage 3: X = A + B*W , Y = A - B*W (combinational here) ----
    wire signed [WIDTH-1:0] x_real_c, x_imag_c, y_real_c, y_imag_c;

    fixed_adder #(.WIDTH(WIDTH)) add_x_real (
        .clk(clk), .rst(rst), .valid_in(1'b1), .subtract(1'b0),
        .a(a_real_d2), .b(bw_real), .result(x_real_c), .overflow(), .valid_out());
    fixed_adder #(.WIDTH(WIDTH)) add_x_imag (
        .clk(clk), .rst(rst), .valid_in(1'b1), .subtract(1'b0),
        .a(a_imag_d2), .b(bw_imag), .result(x_imag_c), .overflow(), .valid_out());
    fixed_adder #(.WIDTH(WIDTH)) add_y_real (
        .clk(clk), .rst(rst), .valid_in(1'b1), .subtract(1'b1),
        .a(a_real_d2), .b(bw_real), .result(y_real_c), .overflow(), .valid_out());
    fixed_adder #(.WIDTH(WIDTH)) add_y_imag (
        .clk(clk), .rst(rst), .valid_in(1'b1), .subtract(1'b1),
        .a(a_imag_d2), .b(bw_imag), .result(y_imag_c), .overflow(), .valid_out());

    // ---- Stage 4: output register (restores 4-cycle latency) ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_real <= 0; x_imag <= 0;
            y_real <= 0; y_imag <= 0;
        end else begin
            x_real <= x_real_c;
            x_imag <= x_imag_c;
            y_real <= y_real_c;
            y_imag <= y_imag_c;
        end
    end

endmodule