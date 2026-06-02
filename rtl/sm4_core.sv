`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/24 15:02:36
// Design Name: 
// Module Name: sm4_core
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
module sm4_core(
    input logic             aclk,
    
    input logic             in_valid,
    output logic            in_ready,
    input logic [127:0]     plaintext,
    input logic [127:0]     key,
    
    output logic            out_valid,
    input logic             out_ready,
    output logic [127:0]    ciphertext
    );
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
    
    // ------------------------
    // 状态机
    // ------------------------
   typedef enum logic {
        IDLE = 'd0,
        WORK = 'd1
    }sta;
    
    sta                 cur_sta = IDLE;
    sta                 nex_sta = IDLE;
    
    // ------------------------
    // 内部寄存器
    // ------------------------
    logic [0:3][31:0]   key_proccess = '{default:'b0};    // 当前处理中的 K 值 (K0..K3) 
    logic [31:0]        t_func_in    = 'b0;               // T 函数输入    
    logic [5:0]         round_cnt    = 'b0;               // 轮次计数器
    logic [2:0]         step_cnt     = 'b0;               // 步骤计数器 (控制内部流水)
    logic [0:3][7:0]    sbox_out     = '{default:'b0};    // SBOX 输出字节
    logic [0:4][31:0]   b_l_func     = '{default:'b0};    // B, B<<<13, B<<<23
    
    
    logic [31:0]      round_key_data;
    logic [5:0]       round_key_cnt;
    
    
    always @(posedge aclk) 
        cur_sta <= nex_sta;
    
    always @(*) begin
        case(cur_sta)
            IDLE : if(in_valid) nex_sta = WORK;
            WORK : if(out_valid) nex_sta = IDLE;
        endcase
    end
    
    always @(posedge aclk) begin
        out_valid <= 1'b0;
        case(cur_sta)
            IDLE : begin
                if(in_valid) begin
                    key_proccess <= '{plaintext[127:96], plaintext[95:64], plaintext[63:32], plaintext[31:0]};
                    round_cnt <= 'b0;
                    in_ready <= 1'b0;
                end else begin
                    in_ready <= 1'b1;
                end
            end
            WORK : begin
                if(round_cnt >= 'd32)out_valid <= 1'b1;
                
                if(step_cnt >= 'd4)step_cnt <= 'd0;
                else step_cnt <= step_cnt + 1'd1;
                
                case(step_cnt)
                    'd0 : begin
                        if(round_key_cnt == round_cnt + 1)
                            t_func_in <= round_key_data ^ key_proccess[1] ^ key_proccess[2] ^ key_proccess[3];
                        else
                            step_cnt <= step_cnt;
                    end
                    'd2 : begin
                        sbox_out[0] <= sbox[t_func_in[31:24]];
                        sbox_out[1] <= sbox[t_func_in[23:16]];
                        sbox_out[2] <= sbox[t_func_in[15: 8]];
                        sbox_out[3] <= sbox[t_func_in[7 : 0]];
                    end
                    'd3 : begin
                        b_l_func[0] <= {sbox_out[0], sbox_out[1], sbox_out[2], sbox_out[3]};
                        b_l_func[1] <= {sbox_out[0][5:0], sbox_out[1], sbox_out[2], sbox_out[3], sbox_out[0][7:6]};
                        b_l_func[2] <= {sbox_out[1][5:0], sbox_out[2], sbox_out[3], sbox_out[0], sbox_out[1][7:6]};
                        b_l_func[3] <= {sbox_out[2][5:0], sbox_out[3], sbox_out[0], sbox_out[1], sbox_out[2][7:6]};
                        b_l_func[4] <= {sbox_out[3], sbox_out[0], sbox_out[1], sbox_out[2]};
                    end
                    'd4 : begin
                        key_proccess [3] <= key_proccess [0] ^ b_l_func[0] ^ b_l_func[1] ^ b_l_func[2] ^ b_l_func[3] ^ b_l_func[4];
                        key_proccess [2] <= key_proccess [3];
                        key_proccess [1] <= key_proccess [2];
                        key_proccess [0] <= key_proccess [1];
                        round_cnt <= round_cnt + 1;
                    end
                endcase
            end
        endcase
    end
    
    assign ciphertext = {key_proccess[3], key_proccess[2], key_proccess[1], key_proccess[0]};
    
    sm4_key_expansion m_sm4_key_expansion(
    .aclk(aclk),
    
    .key_in_valid(in_valid&&in_ready),
    .key_in(key),
    
    .round_key_data(round_key_data),
    .round_key_cnt(round_key_cnt)
    
    );
    
endmodule
