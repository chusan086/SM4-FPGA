# SM4-FPGA

**FPGA implementation of SM4 block cipher (GB/T 32907)**

> SM4 is the Chinese national standard for block cipher, supporting 128-bit keys and 128-bit block size. This project implements SM4 with AXI interface for Zynq PS-PL integration on RK-ZYNQ7100-F.

## Target Board

| Board | Chip |
|-------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## Repository Structure

`
SM4-FPGA/
├── rtl/         # RTL implementation (SystemVerilog)
├── sim/         # Simulation testbenches
├── ip/          # Vivado IP configurations
├── constr/      # Timing & pin constraints
├── scripts/     # Project creation Tcl
├── LICENSE      # MIT
└── README.md
`

## Current Progress

### Implemented

- [x] SM4 core cipher (加解密核心)
- [x] SM4 key expansion (密钥扩展 + 流水线)
- [x] SM4 pipeline (流水线架构)
- [x] SM4 S-box (S盒)
- [x] AXI top interface (AXI总线接口)
- [x] Block Design with Zynq PS (含Zynq PS块设计)

### TODO

- [ ] Full AXI DMA integration
- [ ] Performance optimization
- [ ] Testbench for top-level simulation

--- (中文) ---

**SM4 分组密码算法 FPGA 实现 (GB/T 32907)**

## 目标平台

| 开发板 | 芯片 |
|--------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## 当前进度

### 已完成
- [x] SM4 核心加解密
- [x] SM4 密钥扩展（含流水线）
- [x] SM4 流水线架构
- [x] SM4 S 盒
- [x] AXI 总线接口
- [x] Zynq PS 块设计

### 待实现
- [ ] 完整的 AXI DMA 集成
- [ ] 性能优化
- [ ] 顶层仿真测试