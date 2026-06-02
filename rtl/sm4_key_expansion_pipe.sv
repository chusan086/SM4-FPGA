`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/25 08:50:12
// Design Name: 
// Module Name: sm4_key_expansion_pipe
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
module sm4_key_expansion_pipe(
    input logic                 aclk,
    
    input logic [127:0]         key_in,
    
    //流水线迭代输出，不用握手，直接在外面对齐数据就行
    output logic [0:31][31:0]   round_key_data
    );
    
    // ------------------------
    // 固定参数 FK, CK (标准定义)
    // ------------------------
    parameter reg [0:255][7:0] sbox = '{
	8'hd6, 8'h90, 8'he9, 8'hfe, 8'hcc, 8'he1, 8'h3d, 8'hb7,
	8'h16, 8'hb6, 8'h14, 8'hc2, 8'h28, 8'hfb, 8'h2c, 8'h05,
	8'h2b, 8'h67, 8'h9a, 8'h76, 8'h2a, 8'hbe, 8'h04, 8'hc3,
	8'haa, 8'h44, 8'h13, 8'h26, 8'h49, 8'h86, 8'h06, 8'h99,
	8'h9c, 8'h42, 8'h50, 8'hf4, 8'h91, 8'hef, 8'h98, 8'h7a,
	8'h33, 8'h54, 8'h0b, 8'h43, 8'hed, 8'hcf, 8'hac, 8'h62,
	8'he4, 8'hb3, 8'h1c, 8'ha9, 8'hc9, 8'h08, 8'he8, 8'h95,
	8'h80, 8'hdf, 8'h94, 8'hfa, 8'h75, 8'h8f, 8'h3f, 8'ha6,
	8'h47, 8'h07, 8'ha7, 8'hfc, 8'hf3, 8'h73, 8'h17, 8'hba,
	8'h83, 8'h59, 8'h3c, 8'h19, 8'he6, 8'h85, 8'h4f, 8'ha8,
	8'h68, 8'h6b, 8'h81, 8'hb2, 8'h71, 8'h64, 8'hda, 8'h8b,
	8'hf8, 8'heb, 8'h0f, 8'h4b, 8'h70, 8'h56, 8'h9d, 8'h35,
	8'h1e, 8'h24, 8'h0e, 8'h5e, 8'h63, 8'h58, 8'hd1, 8'ha2,
	8'h25, 8'h22, 8'h7c, 8'h3b, 8'h01, 8'h21, 8'h78, 8'h87,
	8'hd4, 8'h00, 8'h46, 8'h57, 8'h9f, 8'hd3, 8'h27, 8'h52,
	8'h4c, 8'h36, 8'h02, 8'he7, 8'ha0, 8'hc4, 8'hc8, 8'h9e,
	8'hea, 8'hbf, 8'h8a, 8'hd2, 8'h40, 8'hc7, 8'h38, 8'hb5,
	8'ha3, 8'hf7, 8'hf2, 8'hce, 8'hf9, 8'h61, 8'h15, 8'ha1,
	8'he0, 8'hae, 8'h5d, 8'ha4, 8'h9b, 8'h34, 8'h1a, 8'h55,
	8'had, 8'h93, 8'h32, 8'h30, 8'hf5, 8'h8c, 8'hb1, 8'he3,
	8'h1d, 8'hf6, 8'he2, 8'h2e, 8'h82, 8'h66, 8'hca, 8'h60,
	8'hc0, 8'h29, 8'h23, 8'hab, 8'h0d, 8'h53, 8'h4e, 8'h6f,
	8'hd5, 8'hdb, 8'h37, 8'h45, 8'hde, 8'hfd, 8'h8e, 8'h2f,
	8'h03, 8'hff, 8'h6a, 8'h72, 8'h6d, 8'h6c, 8'h5b, 8'h51,
	8'h8d, 8'h1b, 8'haf, 8'h92, 8'hbb, 8'hdd, 8'hbc, 8'h7f,
	8'h11, 8'hd9, 8'h5c, 8'h41, 8'h1f, 8'h10, 8'h5a, 8'hd8,
	8'h0a, 8'hc1, 8'h31, 8'h88, 8'ha5, 8'hcd, 8'h7b, 8'hbd,
	8'h2d, 8'h74, 8'hd0, 8'h12, 8'hb8, 8'he5, 8'hb4, 8'hb0,
	8'h89, 8'h69, 8'h97, 8'h4a, 8'h0c, 8'h96, 8'h77, 8'h7e,
	8'h65, 8'hb9, 8'hf1, 8'h09, 8'hc5, 8'h6e, 8'hc6, 8'h84,
	8'h18, 8'hf0, 8'h7d, 8'hec, 8'h3a, 8'hdc, 8'h4d, 8'h20,
	8'h79, 8'hee, 8'h5f, 8'h3e, 8'hd7, 8'hcb, 8'h39, 8'h48
    };
    parameter logic [0:3][31:0] FK = '{
    32'hA3B1BAC6, 32'h56AA3350, 32'h677D9197, 32'hB27022DC
    };
    parameter logic [0:31][31:0] CK = '{
    32'h00070e15, 32'h1c232a31, 32'h383f464d, 32'h545b6269,
    32'h70777e85, 32'h8c939aa1, 32'ha8afb6bd, 32'hc4cbd2d9,
    32'he0e7eef5, 32'hfc030a11, 32'h181f262d, 32'h343b4249,
    32'h50575e65, 32'h6c737a81, 32'h888f969d, 32'ha4abb2b9,
    32'hc0c7ced5, 32'hdce3eaf1, 32'hf8ff060d, 32'h141b2229,
    32'h30373e45, 32'h4c535a61, 32'h686f767d, 32'h848b9299,
    32'ha0a7aeb5, 32'hbcc3cad1, 32'hd8dfe6ed, 32'hf4fb0209,
    32'h10171e25, 32'h2c333a41, 32'h484f565d, 32'h646b7279
    };
    
    
    // ------------------------
    // 内部寄存器
    // ------------------------
    logic [0:32][0:3][31:0]   key_proccess = '{default:'b0};    // 当前处理中的 K 值 (K0..K3) 
    
    
    always @(posedge aclk)
        key_proccess[0] <= '{key_in[127: 96]^FK[0], key_in[95: 64]^FK[1], 
                                      key_in[63: 32] ^FK[2], key_in[31: 0]^FK[3]};
    
    generate
      for (genvar i = 0; i < 32; i = i + 1) begin : gen_loop
        logic [32:0]            t_func_in    = 'b0;                 // T 函数输入                       
        logic [0:3][7:0]        sbox_out     = '{default:'b0};      // SBOX 输出字节                 
        logic [0:2][31:0]       b_l_func     = '{default:'b0};      // B, B<<<13, B<<<23                     
        logic [0:2][0:3][31:0]  key_step     = '{default:'b0};      // 传递0号数据的值
                                                                                  
        always @(posedge aclk) begin                                      
            t_func_in <= CK[i] ^ key_proccess[i][1] ^ key_proccess[i][2] ^ key_proccess[i][3];
            key_step[0][0] <= key_proccess[i][0];
            key_step[0][1] <= key_proccess[i][1];
            key_step[0][2] <= key_proccess[i][2];
            key_step[0][3] <= key_proccess[i][3];
        end
        
        always @(posedge aclk) begin
            sbox_out[0] <= sbox[t_func_in[31:24]];
            sbox_out[1] <= sbox[t_func_in[23:16]];
            sbox_out[2] <= sbox[t_func_in[15: 8]];
            sbox_out[3] <= sbox[t_func_in[7 : 0]];
            key_step[1][0] <= key_step[0][0];
            key_step[1][1] <= key_step[0][1];
            key_step[1][2] <= key_step[0][2];
            key_step[1][3] <= key_step[0][3];
        end
    
        always @(posedge aclk) begin
            b_l_func[0] <= {sbox_out[0], sbox_out[1], sbox_out[2], sbox_out[3]};
            b_l_func[1] <= {sbox_out[1][2:0], sbox_out[2], sbox_out[3], sbox_out[0], sbox_out[1][7:3]};
            b_l_func[2] <= {sbox_out[2][0], sbox_out[3], sbox_out[0], sbox_out[1], sbox_out[2][7:1]};
            key_step[2][0] <= key_step[1][0];
            key_step[2][1] <= key_step[1][1];
            key_step[2][2] <= key_step[1][2];
            key_step[2][3] <= key_step[1][3];
        end
        
        always @(posedge aclk) begin
             key_proccess [i+1][3] <= key_step[2][0] ^ b_l_func[0] ^ b_l_func[1] ^ b_l_func[2];
             key_proccess [i+1][2] <= key_step[2][3];
             key_proccess [i+1][1] <= key_step[2][2];
             key_proccess [i+1][0] <= key_step[2][1];
        end
        
        assign round_key_data [i] = key_proccess [i+1][3];
      end
    endgenerate
    
    
    
endmodule

