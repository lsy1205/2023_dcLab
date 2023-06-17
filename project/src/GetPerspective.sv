`define M00 00
`define M01 01
`define M10 02
`define M11 03
`define M20 04
`define M21 05
`define M30 06
`define M31 07
`define M26 08
`define M27 09
`define M36 10
`define M37 11
`define M43 12
`define M44 13
`define M53 14
`define M54 15
`define M63 16
`define M64 17
`define M73 18
`define M74 19
`define M56 20
`define M57 21
`define M66 22
`define M67 23
`define M08 24
`define M18 25
`define M28 26
`define M38 27
`define M48 28
`define M58 29
`define M68 30
`define M78 31

module GetPerspective #(
    parameter FRAC_W = 13
) (
    input         i_clk,
    input         i_rst_n,
    input         i_start,
    input  [19:0] i_ul_addr,    // {col, row}
    input  [19:0] i_ur_addr,    // {col, row}
    input  [19:0] i_dr_addr,    // {col, row}
    input  [19:0] i_dl_addr,    // {col, row}

    output [35:0] o_A,
    output [35:0] o_B,
    output [35:0] o_C,
    output [35:0] o_D,
    output [35:0] o_E,
    output [35:0] o_F,
    output [35:0] o_G,
    output [35:0] o_H,
    output        o_valid
);


logic [ 6:0] counter_r, counter_w;
logic        valid_r, valid_w;

logic [35:0] M_r[0:31], M_w[0:31];

logic [35:0] mul0_a, mul1_a, mul2_a, mul3_a, mul4_a, mul5_a;
logic [35:0] mul0_b, mul1_b, mul2_b, mul3_b, mul4_b, mul5_b;
logic [35:0] mul0_ans, mul1_ans, mul2_ans, mul3_ans, mul4_ans, mul5_ans;

logic [35:0] div0_a, div1_a, div2_a;
logic [35:0] div0_b, div1_b, div2_b;
logic [35:0] div0_ans, div1_ans, div2_ans;

assign o_valid = valid_r;

assign o_A = M_r[`M28];
assign o_B = M_r[`M18];
assign o_C = M_r[`M08];
assign o_D = M_r[`M58];
assign o_E = M_r[`M78];
assign o_F = M_r[`M48];
assign o_G = M_r[`M38];
assign o_H = M_r[`M68];


MUL #(.FRAC_W(FRAC_W)) mul_0 (
    .A(mul0_a),
    .B(mul0_b),
    .ANS(mul0_ans)
);
MUL #(.FRAC_W(FRAC_W)) mul_1 (
    .A(mul1_a),
    .B(mul1_b),
    .ANS(mul1_ans)
);
MUL #(.FRAC_W(FRAC_W)) mul_2 (
    .A(mul2_a),
    .B(mul2_b),
    .ANS(mul2_ans)
);
MUL #(.FRAC_W(FRAC_W)) mul_3 (
    .A(mul3_a),
    .B(mul3_b),
    .ANS(mul3_ans)
);
MUL #(.FRAC_W(FRAC_W)) mul_4 (
    .A(mul4_a),
    .B(mul4_b),
    .ANS(mul4_ans)
);
MUL #(.FRAC_W(FRAC_W)) mul_5 (
    .A(mul5_a),
    .B(mul5_b),
    .ANS(mul5_ans)
);

DIV #(.FRAC_W(FRAC_W)) div_0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clken(1'b1),
    .A(div0_a),
    .B(div0_b),
    .ANS(div0_ans)
);
DIV #(.FRAC_W(FRAC_W)) div_1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clken(1'b1),
    .A(div1_a),
    .B(div1_b),
    .ANS(div1_ans)
);
DIV #(.FRAC_W(FRAC_W)) div_2 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clken(1'b1),
    .A(div2_a),
    .B(div2_b),
    .ANS(div2_ans)
);

always_comb begin
    for (integer i = 0; i < 32; i=i+1)  M_w[i] = M_r[i];
    mul0_a = 0; mul0_b = 0;
    mul1_a = 0; mul1_b = 0;
    mul2_a = 0; mul2_b = 0;
    mul3_a = 0; mul3_b = 0;
    mul4_a = 0; mul4_b = 0;
    mul5_a = 0; mul5_b = 0;
    div0_a = 0; div0_b = 0;
    div1_a = 0; div1_b = 0;
    div2_a = 0; div2_b = 0;

    case (counter_r)
        7'd00:   counter_w = (i_start);
        7'd69:   counter_w = 7'd0;
        default: counter_w = counter_r + 1;
    endcase
    valid_w = (counter_r == 7'd69);

    if (i_start) begin
        counter_w = 7'd1;

        M_w[`M00][35:FRAC_W] = i_ul_addr[19:10];
        M_w[`M01][35:FRAC_W] = i_ul_addr[ 9: 0];
        M_w[`M10][35:FRAC_W] = i_dl_addr[19:10] - i_ul_addr[19:10];
        M_w[`M11][35:FRAC_W] = i_dl_addr[ 9: 0] - i_ul_addr[ 9: 0];
        M_w[`M20][35:FRAC_W] = i_dr_addr[19:10] - i_ul_addr[19:10];
        M_w[`M21][35:FRAC_W] = i_dr_addr[ 9: 0] - i_ul_addr[ 9: 0];
        M_w[`M30][35:FRAC_W] = i_ur_addr[19:10] - i_ul_addr[19:10];
        M_w[`M31][35:FRAC_W] = i_ur_addr[ 9: 0] - i_ul_addr[ 9: 0];

        M_w[`M26][35:FRAC_W] = i_dr_addr[19:10] - (i_dr_addr[19:10] << 7);  // *127 = *(128-1)
        M_w[`M27][35:FRAC_W] = i_dr_addr[ 9: 0] - (i_dr_addr[ 9: 0] << 7);  // *127 = *(128-1)
        M_w[`M36][35:FRAC_W] = i_ur_addr[19:10] - (i_ur_addr[19:10] << 7);  // *127 = *(128-1)
        M_w[`M37][35:FRAC_W] = i_ur_addr[ 9: 0] - (i_ur_addr[ 9: 0] << 7);  // *127 = *(128-1)

        M_w[`M43][35:FRAC_W] = i_ul_addr[19:10];
        M_w[`M44][35:FRAC_W] = i_ul_addr[ 9: 0];
        M_w[`M53][35:FRAC_W] = i_dl_addr[19:10] - i_ul_addr[19:10];
        M_w[`M54][35:FRAC_W] = i_dl_addr[ 9: 0] - i_ul_addr[ 9: 0];
        M_w[`M63][35:FRAC_W] = i_dr_addr[19:10] - i_ul_addr[19:10];
        M_w[`M64][35:FRAC_W] = i_dr_addr[ 9: 0] - i_ul_addr[ 9: 0];
        M_w[`M73][35:FRAC_W] = i_ur_addr[19:10] - i_ul_addr[19:10];
        M_w[`M74][35:FRAC_W] = i_ur_addr[ 9: 0] - i_ul_addr[ 9: 0];

        M_w[`M56][35:FRAC_W] = i_dl_addr[19:10] - (i_dl_addr[19:10] << 7);  // *127 = *(128-1)
        M_w[`M57][35:FRAC_W] = i_dl_addr[ 9: 0] - (i_dl_addr[ 9: 0] << 7);  // *127 = *(128-1)
        M_w[`M66][35:FRAC_W] = i_dr_addr[19:10] - (i_dr_addr[19:10] << 7);  // *127 = *(128-1)
        M_w[`M67][35:FRAC_W] = i_dr_addr[ 9: 0] - (i_dr_addr[ 9: 0] << 7);  // *127 = *(128-1)

        M_w[`M08][35:FRAC_W] = 7'd0;    // q1x
        M_w[`M18][35:FRAC_W] = 7'd0;    // q2x - q1x
        M_w[`M28][35:FRAC_W] = 7'd127;  // q3x - q1x
        M_w[`M38][35:FRAC_W] = 7'd127;  // q4x - q1x

        M_w[`M48][35:FRAC_W] = 7'd0;    // q1y
        M_w[`M58][35:FRAC_W] = 7'd127;  // q2y - q1y
        M_w[`M68][35:FRAC_W] = 7'd127;  // q3y - q1y
        M_w[`M78][35:FRAC_W] = 7'd0;    // q4y - q1y
    end


    case (counter_r)
        7'd0: begin
            
        end
        7'd1: begin
            // div row1
            div0_a    = M_r[`M10];
            div0_b    = M_r[`M11];
            div1_a    = M_r[`M18];
            div1_b    = M_r[`M11];
        end
        7'd2: begin
            // div row7
            div0_a    = M_r[`M73];
            div0_b    = M_r[`M74];
            div1_a    = M_r[`M78];
            div1_b    = M_r[`M74];
        end
        7'd17: begin
            // row1
            M_w[`M11] = 1 << FRAC_W;
            M_w[`M10] = div0_ans;
            M_w[`M18] = div1_ans;
            
            // row0
            M_w[`M01] = 0;
            mul0_a    = div0_ans;
            mul0_b    = M_r[`M01];
            M_w[`M00] = $signed(M_r[`M00]) - $signed(mul0_ans);
            mul1_a    = div1_ans;
            mul1_b    = M_r[`M01];
            M_w[`M08] = $signed(M_r[`M08]) - $signed(mul1_ans);

            // row2
            M_w[`M21] = 0;
            mul2_a    = div0_ans;
            mul2_b    = M_r[`M21];
            M_w[`M20] = $signed(M_r[`M20]) - $signed(mul2_ans);
            mul3_a    = div1_ans;
            mul3_b    = M_r[`M21];
            M_w[`M28] = $signed(M_r[`M28]) - $signed(mul3_ans);
            
            // row3
            M_w[`M31] = 0;
            mul4_a    = div0_ans;
            mul4_b    = M_r[`M31];
            M_w[`M30] = $signed(M_r[`M30]) - $signed(mul4_ans);
            mul5_a    = div1_ans;
            mul5_b    = M_r[`M31];
            M_w[`M38] = $signed(M_r[`M38]) - $signed(mul5_ans);
        end
        7'd18: begin
            // div row2
            div0_a    = M_r[`M26];
            div0_b    = M_r[`M20];
            div1_a    = M_r[`M27];
            div1_b    = M_r[`M20];
            div2_a    = M_r[`M28];
            div2_b    = M_r[`M20];

            // row7
            M_w[`M74] = 1 << FRAC_W;
            M_w[`M73] = div0_ans;
            M_w[`M78] = div1_ans;
            
            // row4
            M_w[`M44] = 0;
            mul0_a    = div0_ans;
            mul0_b    = M_r[`M44];
            M_w[`M43] = $signed(M_r[`M43]) - $signed(mul0_ans);
            mul1_a    = div1_ans;
            mul1_b    = M_r[`M44];
            M_w[`M48] = $signed(M_r[`M48]) - $signed(mul1_ans);

            // row5
            M_w[`M54] = 0;
            mul2_a    = div0_ans;
            mul2_b    = M_r[`M54];
            M_w[`M53] = $signed(M_r[`M53]) - $signed(mul2_ans);
            mul3_a    = div1_ans;
            mul3_b    = M_r[`M54];
            M_w[`M58] = $signed(M_r[`M58]) - $signed(mul3_ans);
            
            // row6
            M_w[`M64] = 0;
            mul4_a    = div0_ans;
            mul4_b    = M_r[`M64];
            M_w[`M63] = $signed(M_r[`M63]) - $signed(mul4_ans);
            mul5_a    = div1_ans;
            mul5_b    = M_r[`M64];
            M_w[`M68] = $signed(M_r[`M68]) - $signed(mul5_ans);
        end
        7'd19: begin
            // div row5
            div0_a    = M_r[`M56];
            div0_b    = M_r[`M53];
            div1_a    = M_r[`M57];
            div1_b    = M_r[`M53];
            div2_a    = M_r[`M58];
            div2_b    = M_r[`M53];            
        end
        7'd34: begin
            // row2
            M_w[`M20] = 1 << FRAC_W;
            M_w[`M26] = div0_ans;
            M_w[`M27] = div1_ans;
            M_w[`M28] = div2_ans;

            // row3
            M_w[`M30] = 0;
            mul0_a    = div0_ans;
            mul0_b    = M_r[`M30];
            M_w[`M36] = $signed(M_w[`M36]) - $signed(mul0_ans);
            mul1_a    = div1_ans;
            mul1_b    = M_r[`M30];
            M_w[`M37] = $signed(M_w[`M37]) - $signed(mul1_ans);
            mul2_a    = div2_ans;
            mul2_b    = M_r[`M30];
            M_w[`M38] = $signed(M_w[`M38]) - $signed(mul2_ans);
        end
        7'd35: begin
            // div row3
            div0_a    = M_r[`M37];
            div0_b    = M_r[`M36];
            div1_a    = M_r[`M38];
            div1_b    = M_r[`M36];

            // row5
            M_w[`M53] = 1 << FRAC_W;
            M_w[`M56] = div0_ans;
            M_w[`M57] = div1_ans;
            M_w[`M58] = div2_ans;

            // row6
            M_w[`M63] = 0;
            mul0_a    = div0_ans;
            mul0_b    = M_r[`M63];
            M_w[`M66] = $signed(M_w[`M66]) - $signed(mul0_ans);
            mul1_a    = div1_ans;
            mul1_b    = M_r[`M63];
            M_w[`M67] = $signed(M_w[`M67]) - $signed(mul1_ans);
            mul2_a    = div2_ans;
            mul2_b    = M_r[`M63];
            M_w[`M68] = $signed(M_w[`M68]) - $signed(mul2_ans);
        end
        7'd51: begin
            // row3
            M_w[`M36] = 1 << FRAC_W;
            M_w[`M37] = div0_ans;
            M_w[`M38] = div1_ans;

            // row2
            M_w[`M26] = 0;
            mul0_a    = M_r[`M26];
            mul0_b    = div0_ans;
            M_w[`M27] = $signed(M_w[`M27]) - $signed(mul0_ans);
            mul1_a    = M_r[`M26];
            mul1_b    = div1_ans;
            M_w[`M28] = $signed(M_w[`M28]) - $signed(mul1_ans);

            // row5
            M_w[`M56] = 0;
            mul4_a    = M_r[`M56];
            mul4_b    = div0_ans;
            M_w[`M57] = $signed(M_w[`M57]) - $signed(mul4_ans);
            mul5_a    = M_r[`M56];
            mul5_b    = div1_ans;
            M_w[`M58] = $signed(M_w[`M58]) - $signed(mul5_ans);

            // row6
            M_w[`M66] = 0;
            mul2_a    = M_r[`M66];
            mul2_b    = div0_ans;
            M_w[`M67] = $signed(M_w[`M67]) - $signed(mul2_ans);
            mul3_a    = M_r[`M66];
            mul3_b    = div1_ans;
            M_w[`M68] = $signed(M_w[`M68]) - $signed(mul3_ans);
        end
        7'd52: begin
            // div row6
            div0_a    = M_r[`M68];
            div0_b    = M_r[`M67];
        end
        7'd68: begin
            // row6
            M_w[`M67] = 1 << FRAC_W;
            M_w[`M68] = div0_ans;

            // row2
            M_w[`M27] = 0;
            mul0_a    = div0_ans;
            mul0_b    = M_r[`M27];
            M_w[`M28] = M_r[`M28] - mul0_ans;

            // row3
            M_w[`M37] = 0;
            mul2_a    = div0_ans;
            mul2_b    = M_r[`M37];
            M_w[`M38] = M_r[`M38] - mul2_ans;

            // row5
            M_w[`M57] = 0;
            mul1_a    = div0_ans;
            mul1_b    = M_r[`M57];
            M_w[`M58] = M_r[`M58] - mul1_ans;
        end
        7'd69: begin
            // row0
            mul0_a    = M_r[`M00];
            mul0_b    = M_r[`M28];
            M_w[`M08] = M_r[`M08] - mul0_ans;

            // row1
            mul1_a    = M_r[`M10];
            mul1_b    = M_r[`M28];
            M_w[`M18] = M_r[`M18] - mul1_ans;

            // row4
            mul2_a    = M_r[`M43];
            mul2_b    = M_r[`M58];
            M_w[`M48] = M_r[`M48] - mul2_ans;
            
            // row7
            mul3_a    = M_r[`M73];
            mul3_b    = M_r[`M58];
            M_w[`M78] = M_r[`M78] - mul3_ans;
        end
        default: begin
            
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        counter_r <= 0;
        valid_r   <= 0;
        for (integer i = 0; i < 32; i=i+1)  M_r[i] <= 0;
    end
    else begin
        counter_r <= counter_w;
        valid_r   <= valid_w;
        for (integer i = 0; i < 32; i=i+1)  M_r[i] <= M_w[i];
    end
end

endmodule


module MUL #(
    parameter FRAC_W = 13
)(
    input  [35:0] A,
    input  [35:0] B,
    output [35:0] ANS
);

localparam MAX = {1'b0, {35{1'b1}}};
localparam MIN = {1'b1, {35{1'b0}}};

logic overflow;
logic [71:0] mul_result;

assign mul_result = $signed(A) * $signed(B);
assign ANS = overflow ? ((A[35] ^ B[35]) ? MIN : MAX) :
                        mul_result[FRAC_W +: 36];

always_comb begin
    if (&(mul_result[71:FRAC_W+35]) || !(mul_result[71:FRAC_W+35])) begin
        overflow = 0;
    end
    else begin
        overflow = 1;
    end
end

endmodule


module DIV #(
    parameter FRAC_W = 13
) (
    input  i_clk,
    input  i_rst_n,
    input  i_clken,
    input  [35:0] A,
    input  [35:0] B,
    output [35:0] ANS
);

localparam MAX = {1'b0, {35{1'b1}}};
localparam MIN = {1'b1, {35{1'b0}}};

logic overflow;
logic [47:0] numerA;
logic [39:0] denomB;
logic [47:0] div_result;

assign numerA = $signed(A) << FRAC_W;
assign denomB = $signed(B);
assign ANS = overflow ? ((A[35] ^ B[35]) ? MIN : MAX) :
                        div_result[35:0];

Div div_Div_0 (
    .clock(i_clk),
    .aclr(~i_rst_n),
    .clken(i_clken),
    .numer(numerA),
    .denom(denomB),
    .quotient(div_result)
);
    
always_comb begin
    if (&(div_result[47:35]) || !(div_result[47:35])) begin
        overflow = 0;
    end
    else begin
        overflow = 1;
    end
end

endmodule
