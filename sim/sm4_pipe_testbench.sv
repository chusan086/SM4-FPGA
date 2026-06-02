`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/25 09:28:53
// Design Name: 
// Module Name: sm4_pipe_testbench
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
module sm4_pipe_testbench;

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
    sm4_pipe uut (
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
        // 密文681EDF34D206965E86B3E94F536E4246 002A8A4EFA863CCAD024AC0300BB40D2
        @(posedge clk);
        plaintext <= 128'h0123456789abcdeffedcba9876543210;  // 测试明文
        key       <= 128'h0123456789abcdeffedcba9876543210;  // 测试密钥
        in_valid  <= 1;
        
        
        // 密文B2B39A1B91A4E24FA89155E82CF4776D A82679F39B30EF738000B5421E005672
        @(posedge clk);
        plaintext <= 128'h00112233445566778899AABBCCDDEEFF;  // 测试明文
        key       <= 128'h00112233445566778899AABBCCDDEEFF;  // 测试密钥
        in_valid  <= 1;
        
        // 密文14912B8CBCC32F01D4509E16C937A9CB A89924F0F3DFC40B72C42518122C5E81
        @(posedge clk);
        plaintext <= 128'hFFEEDDCCBBAA99887766554433221100;  // 测试明文
        key       <= 128'hFFEEDDCCBBAA99887766554433221100;  // 测试密钥
        in_valid  <= 1;

        @(posedge clk);
        in_valid  <= 0;
    end

endmodule

