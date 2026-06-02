# SM4-FPGA

**FPGA implementation of SM4 block cipher (GB/T 32907)**

> SM4 is the Chinese national standard for block cipher, supporting 128-bit keys and 128-bit block size.

## Target Board

| Board | Chip |
|-------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## Repository Structure

```
SM4-FPGA/
├── rtl/         # RTL implementation (SystemVerilog)
├── sim/         # Simulation testbenches
├── ip/          # Vivado IP core configurations
├── constr/      # Pin and timing constraints
├── bd/          # Block Design (Zynq PS)
├── scripts/     # Project recreation scripts
├── LICENSE      # MIT License
└── README.md
```

## Current Progress

### Implemented

- [x] SM4 core cipher (encryption / decryption)
- [x] SM4 key expansion (pipelined)
- [x] SM4 pipeline architecture
- [x] SM4 S-box
- [x] AXI top interface
- [x] Block Design with Zynq PS

### TODO

- [ ] Full AXI DMA integration
- [ ] Performance optimization
- [ ] Top-level simulation testbench

---

中文说明

## 目标平台

| 开发板 | 芯片 |
|--------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

### 当前进度

- [x] SM4 加解密核心
- [x] SM4 密钥扩展
- [x] SM4 S盒
- [x] AXI 总线接口
