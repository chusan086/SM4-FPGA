`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/24 20:45:33
// Design Name: 
// Module Name: sm4_core_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module sm4_core_testbench;

    // 时钟与复位
    logic clk;
    logic rst_n;

    // DUT 接口信号
    logic             in_valid;
    logic             in_ready;
    logic [127:0]     plaintext;
    logic [127:0]     key;

    logic             out_valid;
    logic             out_ready;
    logic [127:0]     ciphertext;

    // ------------------------
    // DUT 实例化
    // ------------------------
    sm4_core uut (
        .aclk       (clk),
        .in_valid   (in_valid),
        .in_ready   (in_ready),
        .plaintext  (plaintext),
        .key        (key),
        .out_valid  (out_valid),
        .out_ready  (out_ready),
        .ciphertext (ciphertext)
    );

    // ------------------------
    // 时钟生成
    // ------------------------
    initial clk = 0;
    always #5 clk = ~clk;   // 100MHz

    // ------------------------
    // 测试激励
    // ------------------------
    initial begin
        // 初始值
        rst_n     <= 0;
        in_valid  <= 0;
        plaintext <= 128'h0;
        key       <= 128'h0;
        out_ready <= 1;   // 永远准备好接收输出

        // 复位一段时间
        #20;
        rst_n <= 1;

        // 等待几个周期后输入数据
        @(posedge clk);
        plaintext <= 128'h0123456789abcdeffedcba9876543210;  // 测试明文
        key       <= 128'h0123456789abcdeffedcba9876543210;  // 测试密钥
        in_valid  <= 1;

        // 等待 DUT 拉高 in_ready
        wait(in_ready == 1);
        @(posedge clk);
        in_valid <= 0;

        // 等待输出有效
        wait(out_valid == 1);
        $display("[%0t] Ciphertext = %h", $time, ciphertext);

        // 结束仿真
        #20;
        $finish;
    end

endmodule
