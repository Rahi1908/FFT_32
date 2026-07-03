`timescale 1ns / 1ps


module fft_memory (
    input  wire        clk,

    input  wire [4:0]  wr_addr_a,
    input  wire [47:0] wr_data_a,     
    input  wire        wr_en_a,

    input  wire [4:0]  wr_addr_b,
    input  wire [47:0] wr_data_b,    
    input  wire        wr_en_b,

    input  wire [4:0]  rd_addr_a,
    output wire [47:0] rd_data_a,    

    input  wire [4:0]  rd_addr_b,
    output wire [47:0] rd_data_b      
);

    // memory array: 32 locations x 48 bits (was 32 x 32)
    reg [47:0] sample_mem [31:0];

    assign rd_data_a = sample_mem[rd_addr_a];
    assign rd_data_b = sample_mem[rd_addr_b];

    always @(posedge clk) begin
        if (wr_en_a) begin
            sample_mem[wr_addr_a] <= wr_data_a;
        end
        if (wr_en_b) begin
            sample_mem[wr_addr_b] <= wr_data_b;
        end
    end

endmodule
