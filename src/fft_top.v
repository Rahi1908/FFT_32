`timescale 1ns / 1ps

module fft_top (
    input  wire        clk,
    input  wire        reset,

    input  wire        in_push,
    input  wire [15:0] in_real,      // external: Q2.14 (unchanged)
    input  wire [15:0] in_imag,      // external: Q2.14 (unchanged)
    output wire        in_stall,

    output reg          out_push,
    output reg  [15:0] out_real,      // external: Q2.14 (unchanged)
    output reg  [15:0] out_imag,      // external: Q2.14 (unchanged)
    input  wire         out_stall
);

    // ---- widen inputs: Q2.14 (16-bit) -> Q2.22 (24-bit) ----
    wire signed [23:0] in_real_q22;
    wire signed [23:0] in_imag_q22;

    q_widen widen_real (.in_q14(in_real), .out_q22(in_real_q22));
    q_widen widen_imag (.in_q14(in_imag), .out_q22(in_imag_q22));

    // Internal signals - all widened to Q2.22 (24-bit data, 48-bit packed)

    wire [4:0]  rd_addr_a;
    wire [47:0] rd_data_a;      // widened
    wire [4:0]  rd_addr_b;
    wire [47:0] rd_data_b;      // widened

    wire [4:0]  wr_addr_a;
    wire [47:0] wr_data_a;      // widened
    wire [47:0] wr_data_a_muxed; // widened
    wire         wr_en_a;

    wire [4:0]  wr_addr_b;
    wire [47:0] wr_data_b;      // widened
    wire         wr_en_b;

    wire         wr_back;

    wire [3:0]  tw_addr;
    wire [47:0] tw_data;        // widened

    wire [47:0] bfly_x;         // widened
    wire [47:0] bfly_y;         // widened

    wire out_push_int;


    assign wr_data_a_muxed = (wr_back == 1'b1) ? bfly_x : wr_data_a;


    // Instantiate modules

    fft_control fft_control_0 (
        .clk            (clk),
        .reset          (reset),
        .in_push        (in_push),
        .in_real        (in_real_q22),   
        .in_imag        (in_imag_q22),  
        .in_stall_reg   (in_stall),
        .rd_addr_a_reg  (rd_addr_a),
        .rd_addr_b_reg  (rd_addr_b),
        .tw_addr_reg    (tw_addr),
        .wr_addr_a_reg  (wr_addr_a),
        .wr_data_a_reg  (wr_data_a),
        .wr_en_a_reg    (wr_en_a),
        .wr_addr_b_reg  (wr_addr_b),
        .wr_en_b_reg    (wr_en_b),
        .wr_back_reg    (wr_back),
        .out_push_reg   (out_push_int),
        .out_stall      (out_stall)
    );

    fft_memory fft_memory_0 (
        .clk         (clk),
        .wr_addr_a   (wr_addr_a),
        .wr_data_a   (wr_data_a_muxed),
        .wr_en_a     (wr_en_a),
        .wr_addr_b   (wr_addr_b),
        .wr_data_b   (bfly_y),
        .wr_en_b     (wr_en_b),
        .rd_addr_a   (rd_addr_a),
        .rd_data_a   (rd_data_a),
        .rd_addr_b   (rd_addr_b),
        .rd_data_b   (rd_data_b)
    );

    twiddle_rom twiddle_rom_0 (
        .addr         (tw_addr),
        .twiddle_out  (tw_data)
    );

    butterfly #(.WIDTH(24), .FRAC(22)) butterfly_0 (
        .clk     (clk),
        .rst     (reset),
        .a_real  (rd_data_a[47:24]),
        .a_imag  (rd_data_a[23:0]),
        .b_real  (rd_data_b[47:24]),
        .b_imag  (rd_data_b[23:0]),
        .w_real  (tw_data[47:24]),
        .w_imag  (tw_data[23:0]),
        .x_real  (bfly_x[47:24]),
        .x_imag  (bfly_x[23:0]),
        .y_real  (bfly_y[47:24]),
        .y_imag  (bfly_y[23:0])
    );


    // ---- narrow outputs: Q2.22 (24-bit) -> Q2.14 (16-bit) ----
    wire signed [15:0] out_real_narrowed;
    wire signed [15:0] out_imag_narrowed;
    wire narrow_overflow_real, narrow_overflow_imag;

    q_narrow narrow_real (
        .in_q22   (rd_data_a[47:24]),
        .out_q14  (out_real_narrowed),
        .overflow (narrow_overflow_real)
    );
    q_narrow narrow_imag (
        .in_q22   (rd_data_a[23:0]),
        .out_q14  (out_imag_narrowed),
        .overflow (narrow_overflow_imag)
    );

    // Output register
    always @(posedge clk) begin
        out_push <= out_push_int;
        out_real <= out_real_narrowed;
        out_imag <= out_imag_narrowed;
    end

endmodule