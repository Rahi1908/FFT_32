`timescale 1ns / 1ps

module fft_control (
    input  wire        clk,
    input  wire        reset,

    input  wire        in_push,
    input  wire [23:0] in_real,
    input  wire [23:0] in_imag,
    output reg         in_stall_reg,

    output reg  [4:0]  rd_addr_a_reg,
    output reg  [4:0]  rd_addr_b_reg,
    output reg  [3:0]  tw_addr_reg,

    output reg  [4:0]  wr_addr_a_reg,
    output reg  [47:0] wr_data_a_reg,
    output reg          wr_en_a_reg,
    output reg  [4:0]  wr_addr_b_reg,
    output reg          wr_en_b_reg,
    output reg          wr_back_reg,

    output reg          out_push_reg,
    input  wire         out_stall
);

    localparam INPUT        = 2'b00;
    localparam COMPUTE      = 2'b01;
    localparam OUTPUT       = 2'b10;

    reg [1:0] state_reg;
    reg [1:0] state_next;

    reg          in_stall;

    reg  [4:0]  rd_addr_a;
    reg  [4:0]  rd_addr_b;
    wire [3:0]  tw_addr;

    reg  [4:0]  wr_addr_a;
    reg  [47:0] wr_data_a;
    reg          wr_en_a;
    reg  [4:0]  wr_addr_b;
    reg          wr_en_b;
    reg          wr_back;

    reg  [4:0]  count_reg;
    reg  [4:0]  count;

    reg  [2:0]  stage_reg;
    reg  [2:0]  stage;

    reg  [3:0]  bfly_reg;
    reg  [3:0]  bfly;

    reg  [2:0]  drain_reg;
    reg  [2:0]  drain;
    reg          draining_reg;
    reg          draining;

    wire [4:0]  addr_a;
    reg  [4:0]  addr_a_reg;
    reg  [4:0]  addr_a_d2;
    reg  [4:0]  addr_a_d3;
    reg  [4:0]  addr_a_d4;
    wire [4:0]  addr_b;
    reg  [4:0]  addr_b_reg;
    reg  [4:0]  addr_b_d2;
    reg  [4:0]  addr_b_d3;
    reg  [4:0]  addr_b_d4;

    reg          out_push;


    addr_gen_lut addr_gen_lut_0 (
        .stage_num  (stage_reg),
        .bfly_num   (bfly_reg),
        .addr_a     (addr_a),
        .addr_b     (addr_b),
        .tw_addr    (tw_addr)
    );


    always @(*) begin

        state_next = state_reg;
        in_stall = 1'b1;

        rd_addr_a = rd_addr_a_reg;
        rd_addr_b = rd_addr_b_reg;

        wr_addr_a = wr_addr_a_reg;
        wr_data_a = wr_data_a_reg;
        wr_en_a   = 1'b0;
        wr_addr_b = wr_addr_b_reg;
        wr_en_b   = 1'b0;
        wr_back   = 1'b0;

        out_push = 1'b0;

        count = count_reg;
        stage = stage_reg;
        bfly  = bfly_reg;

        drain = drain_reg;
        draining = draining_reg;

        case (state_reg)

            INPUT: begin

                in_stall = 1'b0;

                if (in_stall_reg == 1'b0 && in_push == 1'b1) begin
                    wr_addr_a = {count_reg[0], count_reg[1], count_reg[2], count_reg[3], count_reg[4]};
                    wr_data_a = {in_real, in_imag};
                    wr_en_a   = 1'b1;
                    count = count_reg + 1;
                end

                if (count_reg == 31) begin
                    state_next = COMPUTE;
                    count = 0;
                end

            end

            COMPUTE: begin

                // pipeline write-backs happen every cycle here, unconditionally
                wr_addr_a = addr_a_d4;
                wr_addr_b = addr_b_d4;
                wr_en_a = 1'b1;
                wr_en_b = 1'b1;
                wr_back = 1'b1;

                if (draining_reg == 1'b0) begin
                    rd_addr_a = addr_a;
                    rd_addr_b = addr_b;
                    bfly = bfly_reg + 1;

                    if (bfly_reg == 15) begin
                        stage = stage_reg + 1;
                        if (stage_reg == 4) begin
                            draining = 1'b1;
                            drain = 0;
                        end
                    end

                end else begin
                    drain = drain_reg + 1;
                    if (drain_reg == 3) begin
                        state_next = OUTPUT;
                        draining = 1'b0;
                        drain = 0;
                        count = 0;
                    end
                end

            end

            OUTPUT: begin

                out_push = 1'b1;
                rd_addr_a = count_reg;
                rd_addr_b = 5'b0;
                count = count_reg + 1;

                if (count_reg == 31) begin
                    state_next = INPUT;
                    count = 0;
                    stage = 0;
                    bfly  = 0;
                end

            end

        endcase

    end


    always @(posedge clk) begin

        if (reset == 1'b1) begin

            state_reg <= INPUT;
            in_stall_reg <= 1'b1;

            rd_addr_a_reg <= 0;
            rd_addr_b_reg <= 0;
            tw_addr_reg   <= 0;

            wr_addr_a_reg <= 0;
            wr_data_a_reg <= 0;
            wr_en_a_reg   <= 1'b0;
            wr_addr_b_reg <= 0;
            wr_en_b_reg   <= 1'b0;
            wr_back_reg   <= 1'b0;

            out_push_reg <= 1'b0;

            count_reg <= 0;
            stage_reg <= 0;
            bfly_reg  <= 0;

            drain_reg    <= 0;
            draining_reg <= 1'b0;

            addr_a_reg <= 0; addr_a_d2 <= 0; addr_a_d3 <= 0; addr_a_d4 <= 0;
            addr_b_reg <= 0; addr_b_d2 <= 0; addr_b_d3 <= 0; addr_b_d4 <= 0;

        end else begin

            state_reg <= state_next;
            in_stall_reg <= in_stall;

            rd_addr_a_reg <= rd_addr_a;
            rd_addr_b_reg <= rd_addr_b;
            tw_addr_reg   <= tw_addr;

            wr_addr_a_reg <= wr_addr_a;
            wr_data_a_reg <= wr_data_a;
            wr_en_a_reg   <= wr_en_a;
            wr_addr_b_reg <= wr_addr_b;
            wr_en_b_reg   <= wr_en_b;
            wr_back_reg   <= wr_back;

            out_push_reg <= out_push;

            count_reg <= count;
            stage_reg <= stage;
            bfly_reg  <= bfly;

            drain_reg    <= drain;
            draining_reg <= draining;

            addr_a_reg <= addr_a;
            addr_a_d2  <= addr_a_reg;
            addr_a_d3  <= addr_a_d2;
            addr_a_d4  <= addr_a_d3;

            addr_b_reg <= addr_b;
            addr_b_d2  <= addr_b_reg;
            addr_b_d3  <= addr_b_d2;
            addr_b_d4  <= addr_b_d3;

        end

    end

endmodule