# 32-Point Radix-2 DIT FFT (Fixed-Point, Verilog)

A pipelined, fixed-point 32-point Radix-2 Decimation-In-Time (DIT) FFT core written in Verilog. The design accepts Q2.14 samples externally, computes internally in a widened Q2.22 format for precision headroom, and narrows back to Q2.14 on output. Verified in simulation against a NumPy reference model.

## Overview

- **Size:** 32-point FFT, 5 stages (log2(32) = 5), 16 butterflies per stage
- **Algorithm:** Radix-2 Decimation-In-Time (DIT)
- **Arithmetic:** Fixed-point, saturating, round-to-nearest
  - External I/O: Q2.14 (16-bit)
  - Internal datapath: Q2.22 (24-bit), widened on input and narrowed on output
- **Interface:** Simple streaming push/stall handshake for input and output
- **Memory:** Single dual-port sample RAM (32 x 48-bit, packed real+imag) reused in-place across all stages
- **Twiddle factors:** Precomputed ROM, 16 unique factors (W_32^0 .. W_32^15) in Q2.22

## Architecture

```
 in_real/in_imag (Q2.14)
        |
    [q_widen]  ->  Q2.22
        |
        v
   +---------------------------------------------------------+
   |                        fft_top                          |
   |                                                          |
   |   +--------------+     +--------------+                 |
   |   | fft_control  |<--->| fft_memory   |<---+             |
   |   | (FSM + addr  |     | (32 x 48b    |    |             |
   |   |  sequencing) |     |  dual-port)  |    |             |
   |   +------+-------+     +------+-------+    |             |
   |          |                    |            |             |
   |          v                    v            |             |
   |   +--------------+     rd_data_a/b          |             |
   |   | addr_gen_lut |            |            |             |
   |   +--------------+            v            |             |
   |                        +--------------+     |             |
   |   +--------------+     |  butterfly   |-----+  (x -> A)   |
   |   | twiddle_rom  |---->|  (4-stage    |                   |
   |   +--------------+     |   pipeline)  |------------------>| (y -> B, wr_back mux)
   |                        +--------------+                   |
   +---------------------------------------------------------+
        |
    [q_narrow] -> Q2.14
        |
        v
 out_real/out_imag (Q2.14)
```

The FFT reuses a single 32-word memory for all 5 stages (in-place computation), addressed via a precomputed lookup table (`addr_gen_lut`) that encodes the standard radix-2 DIT butterfly index pattern and twiddle ROM address for each stage/butterfly combination.

## Module Descriptions

| File | Module | Description |
|---|---|---|
| `fft_top.v` | `fft_top` | Top-level wrapper. Widens inputs to Q2.22, narrows outputs to Q2.14, and instantiates/wires the control FSM, memory, twiddle ROM, and butterfly unit. |
| `fft_control.v` | `fft_control` | Main FSM (`INPUT` -> `COMPUTE` -> `OUTPUT`). Sequences sample loading, drives the butterfly pipeline through all 5 stages x 16 butterflies, handles pipeline drain, and streams results out. |
| `addr_gen_lut.v` | `addr_gen_lut` | Combinational lookup table mapping `(stage_num, bfly_num)` to the two operand memory addresses (`addr_a`, `addr_b`) and the twiddle ROM address (`tw_addr`) for that butterfly. |
| `fft_memory.v` | `fft_memory` | Dual read/write port sample memory, 32 x 48-bit words (24-bit real + 24-bit imag packed). Used in-place across all FFT stages. |
| `twiddle_rom.v` | `twiddle_rom` | 16-entry ROM of precomputed twiddle factors `W_32^k = cos(2*pi*k/32) - j*sin(2*pi*k/32)` in Q2.22, packed as `{real[23:0], imag[23:0]}`. |
| `butterfly.v` | `butterfly` | 4-stage pipelined radix-2 butterfly: computes `B*W` (complex multiply), then `X = A + B*W`, `Y = A - B*W`. Delays the `A` operand to match the multiply/add pipeline latency. |
| `fixed_multiplier.v` | `fixed_multiplier` | Parameterized fixed-point multiplier with round-to-nearest and saturation. |
| `fixed_adder.v` | `fixed_adder` | Parameterized fixed-point adder/subtractor with saturation. |
| `q_widen.v` | `q_widen` | Exact sign-extending shift, Q2.14 (16-bit) -> Q2.22 (24-bit). |
| `q_narrow.v` | `q_narrow` | Q2.22 (24-bit) -> Q2.14 (16-bit) with round-to-nearest and saturation. |
| `fft_tb.v` | `fft_tb` | Self-checking-style testbench: streams 32 samples in from `data_in.txt`, captures 32 output samples, writes them to `data_out.txt`, and dumps a VCD waveform. |

## Data Format

- **Q2.14**: 16-bit signed fixed-point, 2 integer bits (including sign), 14 fractional bits. Used at the top-level I/O boundary.
- **Q2.22**: 24-bit signed fixed-point, 2 integer bits (including sign), 22 fractional bits. Used internally for extra precision headroom through the multiply/accumulate chain, then narrowed back down before leaving the core.
- All adders and multipliers saturate on overflow and round to nearest (rather than truncating) when rescaling between formats.

## Control Flow (FSM)

`fft_control` cycles through three states:

1. **INPUT** — Accepts 32 incoming samples one per cycle (bit-reversed addressing into memory) while `in_push` is asserted and `in_stall` is low.
2. **COMPUTE** — Steps through 5 stages x 16 butterflies. For each butterfly, operand addresses and the twiddle address come from `addr_gen_lut`; results are written back in-place 4 cycles later (matching the butterfly unit's pipeline latency). After the last stage, the pipeline is drained for a few extra cycles before moving on.
3. **OUTPUT** — Streams all 32 results out sequentially, respecting `out_stall` backpressure.

## Simulation

The included testbench (`fft_tb.v`) expects a `data_in.txt` file (32 lines, each a 32-bit binary value packing `{in_real, in_imag}` as read via `$readmemb`) and produces `data_out.txt` with the 32 output samples in the same packed binary format, plus a `fft_tb.vcd` waveform dump.

Example with Icarus Verilog:

```bash
iverilog -o fft_sim.vvp fft_top.v fft_control.v fft_memory.v addr_gen_lut.v \
    butterfly.v fixed_adder.v fixed_multiplier.v q_narrow.v q_widen.v \
    twiddle_rom.v fft_tb.v
vvp fft_sim.vvp
```

Make sure `data_in.txt` is present in the run directory before simulating. Output can then be compared against a NumPy (or other) reference FFT for verification.

## Status / Notes

- Functionally verified in simulation against a NumPy floating-point reference FFT.
- Designed for Vivado simulation/synthesis flows but is written in portable, synthesizable Verilog-2001 style.
- Fixed-point rescaling between stages uses round-to-nearest with saturation to control error accumulation across the 5 butterfly stages.

## License

Add a license of your choice (e.g. MIT) here before publishing.
