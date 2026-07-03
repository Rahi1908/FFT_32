
`timescale 1ns / 1ps

module fft_tb;

    reg                clk;
    reg                reset;

    reg                in_push;
    reg  signed [15:0] in_real;
    reg  signed [15:0] in_imag;
    wire               in_stall;

    wire               out_push;
    wire signed [15:0] out_real;
    wire signed [15:0] out_imag;
    reg                out_stall;

    reg  [31:0] sample_mem [0:31];   
    reg  [31:0] out_mem    [0:31];   
    integer     in_idx;
    integer     out_idx;
    integer     out_file;

    // ---- instantiate the design under test ----
    fft_top fft_top_0 (
        .clk        (clk),
        .reset      (reset),
        .in_push    (in_push),
        .in_real    (in_real),
        .in_imag    (in_imag),
        .in_stall   (in_stall),
        .out_push   (out_push),
        .out_real   (out_real),
        .out_imag   (out_imag),
        .out_stall  (out_stall)
    );

    // ---- clock: 100 MHz (10 ns period) ----
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---- load input file into memory ----
    initial begin
        $readmemb("data_in.txt", sample_mem);
    end

    // ---- WATCHDOG: forcibly ends sim if anything hangs ----
    // 32-point FFT: 64 cycles for the burst (32 in + 32 out) * 10ns = 640 ns,
    // plus pipeline latency. 4000 ns gives large margin.
    initial begin
        #4000;
        $display("WATCHDOG: forcing simulation end at time %0t", $time);
        $display("          out_idx reached = %0d (should be 32 if all outputs captured)", out_idx);
        $finish;
    end

    // ---- stimulus ----
    initial begin
        out_file = $fopen("data_out.txt", "w");

        reset     = 1'b1;
        in_push   = 1'b0;
        out_stall = 1'b0;
        in_idx    = 0;
        out_idx   = 0;

        repeat (2) @(posedge clk);
        reset = 1'b0;
        in_push = 1'b1;

        // push all 32 input samples in, one per clock
        for (in_idx = 0; in_idx < 32; in_idx = in_idx + 1) begin
            {in_real, in_imag} = sample_mem[in_idx];
            @(posedge clk);
        end

        in_push = 1'b0;
        @(posedge clk);

        // wait for the FFT to start producing output
        while (out_push == 1'b0) begin
            @(posedge clk);
        end

        // capture 32 output samples
        for (out_idx = 0; out_idx < 32; out_idx = out_idx + 1) begin
            if (out_push === 1'b1 && out_stall === 1'b0) begin
                out_mem[out_idx] = {out_real, out_imag};

                $display("out[%0d] = real:%0d (0x%h)  imag:%0d (0x%h)",
                          out_idx, out_real, out_real, out_imag, out_imag);

                $fwrite(out_file, "%b%b\n", out_real, out_imag);

                @(posedge clk);
            end
        end

        $fclose(out_file);
        $display("Simulation complete: captured %0d output samples.", out_idx);

        repeat (5) @(posedge clk);
        $finish;
    end

    // ---- waveform dump ----
    initial begin
        $dumpfile("fft_tb.vcd");
        $dumpvars(0, fft_tb);
    end

endmodule
