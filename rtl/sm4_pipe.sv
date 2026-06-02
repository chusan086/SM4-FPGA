`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 纯流水线式SM4加密，200M时钟下的带宽大概是20Gbps
// 延迟为132个时钟
//////////////////////////////////////////////////////////////////////////////////
module sm4_pipe(
    input logic             aclk,           // 时钟信号
    
    input logic             in_valid,       // 输入数据有效标志                                   
    output logic            in_ready,       // 输入是否可以接收 (未使用，可扩展)                         
    input logic [127:0]     plaintext,      // 128位明文                                     
    input logic [127:0]     key,            // 128位密钥                                     
    
    output logic            out_valid,      // 输出数据有效标志                               
    input logic             out_ready,      // 输出是否可以被接收 (未使用，可扩展)                        
    output logic [127:0]    ciphertext      // 128位密文                                     
    );                                          
    
    // ------------------------
    // 固定参数 SBOX (标准定义)
    // ------------------------
    // 用于SM4的S盒查找表（8位 -> 8位映射），定义为参数数组
    localparam reg [0:255][7:0] sbox = '{
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
    
    
    // ------------------------
    // 内部寄存器
    // ------------------------
    logic [0:32][0:3][31:0]     text_proccess = '{default:'b0};      // 当前处理中的 K 值 (K0..K3) 
    logic [0:3][127:0]          plaintext_reg = '{default:'b0};     // 输入缓冲器
    logic [132:0]               valid_line = 'b0;                   // 数据有效链
    
    // 密钥拓展的输出接口
    logic [0:31][31:0]          round_key_data;
    
    // ------------------------
    // 有效信号流水线
    // ------------------------
    always @(posedge aclk) valid_line <= {valid_line[131:0],in_valid};
    
    // 第0级，直接采样输入明文
    always @(posedge aclk) plaintext_reg[0] <= plaintext;
    
    // 明文流水线推进 3 级，用于和 key_proccess 初始对齐
    generate
        for (genvar i = 0; i < 3; i = i + 1) begin : plaintext_reg_loop
            always @(posedge aclk) plaintext_reg[i+1] <= plaintext_reg[i];
        
        end
    endgenerate
    
    // ------------------------
    // 初始化 text_proccess[0]
    // ------------------------
    always @(posedge aclk)
        text_proccess[0] <= '{plaintext_reg[3][127:96], plaintext_reg[3][95:64], plaintext_reg[3][63:32], plaintext_reg[3][31:0]};
    
    // ------------------------
    // 主加密流水线 (32轮)
    // ------------------------
    generate
      for (genvar i = 0; i < 32; i = i + 1) begin : gen_loop
        logic [32:0]            t_func_in    = 'b0;                 // T 函数输入                       
        logic [0:3][7:0]        sbox_out     = '{default:'b0};      // SBOX 输出字节                 
        logic [0:4][31:0]       b_l_func     = '{default:'b0};      // B, B<<<13, B<<<23                     
        logic [0:2][0:3][31:0]  text_step   = '{default:'b0};      // 传递0号数据的值
        
        // 计算 T 函数输入                                                                          
        always @(posedge aclk) begin                                      
            t_func_in <= round_key_data[i] ^ text_proccess[i][1] ^ text_proccess[i][2] ^ text_proccess[i][3];
            text_step[0][0] <= text_proccess[i][0];
            text_step[0][1] <= text_proccess[i][1];
            text_step[0][2] <= text_proccess[i][2];
            text_step[0][3] <= text_proccess[i][3];
        end
        
        // SBOX 替代：将32位输入分成4个字节，分别查表
        always @(posedge aclk) begin
            sbox_out[0] <= sbox[t_func_in[31:24]];
            sbox_out[1] <= sbox[t_func_in[23:16]];
            sbox_out[2] <= sbox[t_func_in[15: 8]];
            sbox_out[3] <= sbox[t_func_in[7 : 0]];
            text_step[1][0] <= text_step[0][0];
            text_step[1][1] <= text_step[0][1];
            text_step[1][2] <= text_step[0][2];
            text_step[1][3] <= text_step[0][3];
        end
        
        // 线性变换 L：B, B<<<2, B<<<10, B<<<18, B<<<24 组合
        always @(posedge aclk) begin
            b_l_func[0] <= {sbox_out[0], sbox_out[1], sbox_out[2], sbox_out[3]};
            b_l_func[1] <= {sbox_out[0][5:0], sbox_out[1], sbox_out[2], sbox_out[3], sbox_out[0][7:6]};
            b_l_func[2] <= {sbox_out[1][5:0], sbox_out[2], sbox_out[3], sbox_out[0], sbox_out[1][7:6]};
            b_l_func[3] <= {sbox_out[2][5:0], sbox_out[3], sbox_out[0], sbox_out[1], sbox_out[2][7:6]};
            b_l_func[4] <= {sbox_out[3], sbox_out[0], sbox_out[1], sbox_out[2]};
            text_step[2][0] <= text_step[1][0];
            text_step[2][1] <= text_step[1][1];
            text_step[2][2] <= text_step[1][2];
            text_step[2][3] <= text_step[1][3];
        end
        
        always @(posedge aclk) begin
             text_proccess [i+1][3] <= text_step[2][0]^ b_l_func[0] ^ b_l_func[1] ^ b_l_func[2] ^ b_l_func[3] ^ b_l_func[4];
             text_proccess [i+1][2] <= text_step[2][3];
             text_proccess [i+1][1] <= text_step[2][2];
             text_proccess [i+1][0] <= text_step[2][1];
        end
        
      end
    endgenerate
    
    // ------------------------
    // 输出结果
    // ------------------------
    // 将最后的 X[32] 拼接成 128位密文 (注意 SM4 的输出需要倒序)
    assign ciphertext = {text_proccess[32][3], text_proccess[32][2], text_proccess[32][1], text_proccess[32][0]};
    assign out_valid = valid_line[132];
    
    // ------------------------
    // 密钥扩展模块实例化
    // ------------------------
    sm4_key_expansion_pipe m_sm4_key_expansion_pipe(
    .aclk(aclk),
    
    .key_in(key),
    
    .round_key_data(round_key_data)
    );
    
endmodule

