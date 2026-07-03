# FFT_32
Pipelined 32-point Radix-2 DIT FFT core in Verilog, using fixed-point Q2.14 I/O widened to Q2.22 internally for precision. Features a 4-stage butterfly pipeline, in-place dual-port memory reuse across all 5 stages, and a streaming push/stall interface. Verified through simulations.
