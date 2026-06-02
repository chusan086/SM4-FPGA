`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/27 14:56:41
// Design Name: 
// Module Name: sm4_pipe_test_top
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


module sm4_pipe_test_top(
    input logic             aclk,           // 时钟信号
    output logic            fan_ctrl                                  
    );
    
    clk_wiz_0 m_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(aclk_sm4),     // output clk_out1
   // Clock in ports
    .clk_in1(aclk)      // input clk_in1
    );
    
    sm4_pipe_test m_sm4_pipe_test(
    .aclk(aclk_sm4),           // 时钟信号
    .fan_ctrl(fan_ctrl)                                  
    ); 
    
endmodule
