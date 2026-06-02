# SM4-FPGA

**FPGA implementation of SM4 block cipher (GB/T 32907)**

> SM4 is the Chinese national standard for block cipher, supporting 128-bit keys and 128-bit block size. This project implements SM4 with AXI interface for Zynq PS-PL integration on RK-ZYNQ7100-F.

## Target Board

| Board | Chip |
|-------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## Repository Structure

```
SM4-FPGA/
 +-- rtl/         # RTL implementation (SystemVerilog)
 +-- sim/         # Simulation testbenches
 +-- ip/          # Vivado IP configurations
 +-- constr/      # Timing and pin constraints
 +-- bd/          # Block Design (Zynq PS)
 +-- scripts/     # Project creation Tcl
 +-- LICENSE      # MIT
 +-- README.md
```

## Current Progress

### Implemented

- [x] SM4 core cipher (encryption/decryption)
- [x] SM4 key expansion (pipelined)
- [x] SM4 pipeline architecture
- [x] SM4 S-box
- [x] AXI top interface
- [x] Block Design with Zynq PS

### TODO

- [ ] Full AXI DMA integration
- [ ] Performance optimization
- [ ] Top-level simulation testbench
