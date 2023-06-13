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
    parameter INT_W  = 20,
    parameter FRAC_W = 13
) (
    input        i_clk,
    input        i_rst_n,
    input        i_start,
    input [19:0] i_ul_addr, // first 10 bit is x, last is y
    input [19:0] i_ur_addr,
    input [19:0] i_dr_addr,
    input [19:0] i_dl_addr,

    output [INT_W + FRAC_W - 1:0] A,
    output [INT_W + FRAC_W - 1:0] B,
    output [INT_W + FRAC_W - 1:0] C,
    output [INT_W + FRAC_W - 1:0] D,
    output [INT_W + FRAC_W - 1:0] E,
    output [INT_W + FRAC_W - 1:0] F,
    output [INT_W + FRAC_W - 1:0] G,
    output [INT_W + FRAC_W - 1:0] H,
    output                        o_valid
);

localparam S_IDLE = 0;
localparam S_CALC = 1;

localparam WIDTH = INT_W + FRAC_W;

localparam q1x = 7'd00;
localparam q1y = 7'd00;
localparam q2x = 7'd00;
localparam q2y = 7'd99;
localparam q3x = 7'd99;
localparam q3y = 7'd99;
localparam q4x = 7'd99;
localparam q4y = 7'd00;

logic               state_r, state_w;
logic [        2:0] counter_r, counter_w;
logic [WIDTH - 1:0] M_r [0:31];
logic [WIDTH - 1:0] M_w [0:31];
logic [INT_W - 1:0] temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7;
logic [WIDTH - 1:0] mul0_a, mul0_b, mul1_a, mul1_b, mul2_a, mul2_b;
logic [WIDTH - 1:0] mul3_a, mul3_b, mul4_a, mul4_b, mul5_a, mul5_b;
logic [WIDTH - 1:0] div0_a, div0_b, div1_a, div1_b, div2_a, div2_b;
logic [WIDTH - 1:0] mul0_ans, mul1_ans, mul2_ans;
logic [WIDTH - 1:0] mul3_ans, mul4_ans, mul5_ans;
logic [WIDTH - 1:0] div0_ans, div1_ans, div2_ans;
logic               valid_r, valid_w;
logic [WIDTH - 1:0] matrix_r [0:7];
logic [WIDTH - 1:0] matrix_w [0:7];

assign o_valid = valid_r;
assign A = matrix_r[0];
assign B = matrix_r[1];
assign C = matrix_r[2];
assign D = matrix_r[3];
assign E = matrix_r[4];
assign F = matrix_r[5];
assign G = matrix_r[6];
assign H = matrix_r[7];

mul #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) mul0 (
    .A(mul0_a),
    .B(mul0_b),
    .ANS(mul0_ans)
);
mul #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) mul1 (
    .A(mul1_a),
    .B(mul1_b),
    .ANS(mul1_ans)
);
mul #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) mul2 (
    .A(mul2_a),
    .B(mul2_b),
    .ANS(mul2_ans)
);
mul #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) mul3 (
    .A(mul3_a),
    .B(mul3_b),
    .ANS(mul3_ans)
);
mul #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) mul4 (
    .A(mul4_a),
    .B(mul4_b),
    .ANS(mul4_ans)
);
mul #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) mul5 (
    .A(mul5_a),
    .B(mul5_b),
    .ANS(mul5_ans)
);

div #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) div0 (
    .A(div0_a),
    .B(div0_b),
    .ANS(div0_ans)
);
div #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) div1 (
    .A(div1_a),
    .B(div1_b),
    .ANS(div1_ans)
);
div #(
    .INT_W(INT_W),
    .FRAC_W(FRAC_W)
) div2 (
    .A(div2_a),
    .B(div2_b),
    .ANS(div2_ans)
);

always_comb begin
    state_w = state_r;
    case (state_r)
        S_IDLE: begin
            if (i_start) begin
                state_w = S_CALC;
            end
            else begin
                state_w = S_IDLE;
            end
        end 
        S_CALC: begin
            if (valid_w) begin
                state_w = S_IDLE;
            end
            else begin
                state_w = S_CALC;
            end
        end
        default: begin
            state_w = S_IDLE;
        end
    endcase
end

always_comb begin
    valid_w = 0;
    for (integer i = 0;i < 32;i = i + 1) begin
        M_w[i] = M_r[i];
    end
    for (integer i = 0;i < 8;i = i + 1) begin
        matrix_w = matrix_r;
    end
    temp0 = 0;
    temp1 = 0;
    temp2 = 0;
    temp3 = 0;
    temp4 = 0;
    temp5 = 0;
    temp6 = 0;
    temp7 = 0;
    mul0_a = 0;
    mul0_b = 0;
    mul1_a = 0;
    mul1_b = 0;
    mul2_a = 0;
    mul2_b = 0;
    mul3_a = 0;
    mul3_b = 0;
    mul4_a = 0;
    mul4_b = 0;
    mul5_a = 0;
    mul5_b = 0;
    div0_a = 0;
    div0_b = 0;
    div1_a = 0;
    div1_b = 0;
    div2_a = 0;
    div2_b = 0;
    counter_w = counter_r;
    case (state_r)
        S_IDLE: begin
            if (i_start) begin
                M_w[`M00][WIDTH - 1:FRAC_W] = i_ul_addr[19:10];
                M_w[`M01][WIDTH - 1:FRAC_W] = i_ul_addr[ 9: 0];
                M_w[`M10][WIDTH - 1:FRAC_W] = i_dl_addr[19:10] - i_ul_addr[19:10];
                M_w[`M11][WIDTH - 1:FRAC_W] = i_dl_addr[ 9: 0] - i_ul_addr[ 9: 0];
                M_w[`M20][WIDTH - 1:FRAC_W] = i_dr_addr[19:10] - i_ul_addr[19:10];
                M_w[`M21][WIDTH - 1:FRAC_W] = i_dr_addr[ 9: 0] - i_ul_addr[ 9: 0];
                M_w[`M30][WIDTH - 1:FRAC_W] = i_ur_addr[19:10] - i_ul_addr[19:10];
                M_w[`M31][WIDTH - 1:FRAC_W] = i_ur_addr[ 9: 0] - i_ul_addr[ 9: 0];
                temp0    = (i_dr_addr[19:10] << 1) + i_dr_addr[19:10];
                M_w[`M26][WIDTH - 1:FRAC_W] = -((temp0 << 5) + temp0);
                temp1    = (i_dr_addr[9:0] << 1) + i_dr_addr[9:0];
                M_w[`M27][WIDTH - 1:FRAC_W] = -((temp1 << 5) + temp1);
                temp2    = (i_ur_addr[19:10] << 1) + i_ur_addr[19:10];
                M_w[`M36][WIDTH - 1:FRAC_W] = -((temp2 << 5) + temp2);
                temp3    = (i_ur_addr[9:0] << 1) + i_ur_addr[9:0];
                M_w[`M37][WIDTH - 1:FRAC_W] = -((temp3 << 5) + temp3);
                M_w[`M43][WIDTH - 1:FRAC_W] = i_ul_addr[19:10];
                M_w[`M44][WIDTH - 1:FRAC_W] = i_ul_addr[ 9: 0];
                M_w[`M53][WIDTH - 1:FRAC_W] = i_dl_addr[19:10] - i_ul_addr[19:10];
                M_w[`M54][WIDTH - 1:FRAC_W] = i_dl_addr[ 9: 0] - i_ul_addr[ 9: 0];
                M_w[`M63][WIDTH - 1:FRAC_W] = i_dr_addr[19:10] - i_ul_addr[19:10];
                M_w[`M64][WIDTH - 1:FRAC_W] = i_dr_addr[ 9: 0] - i_ul_addr[ 9: 0];
                M_w[`M73][WIDTH - 1:FRAC_W] = i_ur_addr[19:10] - i_ul_addr[19:10];
                M_w[`M74][WIDTH - 1:FRAC_W] = i_ur_addr[ 9: 0] - i_ul_addr[ 9: 0];
                temp4    = (i_dl_addr[19:10] << 1) + i_dl_addr[19:10];
                M_w[`M56][WIDTH - 1:FRAC_W] = -((temp4 << 5) + temp4);
                temp5    = (i_dl_addr[9:0] << 1) + i_dl_addr[9:0];
                M_w[`M57][WIDTH - 1:FRAC_W] = -((temp5 << 5) + temp5);
                temp6    = (i_dr_addr[19:10] << 1) + i_dr_addr[19:10];
                M_w[`M66][WIDTH - 1:FRAC_W] = -((temp6 << 5) + temp6);
                temp7    = (i_dr_addr[9:0] << 1) + i_dr_addr[9:0];
                M_w[`M67][WIDTH - 1:FRAC_W] = -((temp7 << 5) + temp7);
                M_w[`M08][WIDTH - 1:FRAC_W] = q1x;
                M_w[`M18][WIDTH - 1:FRAC_W] = q2x - q1x;
                M_w[`M28][WIDTH - 1:FRAC_W] = q3x - q1x;
                M_w[`M38][WIDTH - 1:FRAC_W] = q4x - q1x;
                M_w[`M48][WIDTH - 1:FRAC_W] = q1y;
                M_w[`M58][WIDTH - 1:FRAC_W] = q2y - q1y;
                M_w[`M68][WIDTH - 1:FRAC_W] = q3y - q1y;
                M_w[`M78][WIDTH - 1:FRAC_W] = q4y - q1y;
            end
            else begin
            end
        end
        S_CALC: begin
            counter_w = counter_r + 1;
            case (counter_r)
                0: begin
                    // row1
                    M_w[`M11] = 8192;
                    div0_a   = M_r[`M10];
                    div0_b   = M_r[`M11];
                    M_w[`M10] = div0_ans;

                    div1_a   = M_r[`M18];
                    div1_b   = M_r[`M11];
                    M_w[`M18] = div1_ans;
                    
                    // row0
                    M_w[`M01] = 0;
                    mul0_a   = div0_ans;
                    mul0_b   = M_r[`M01];
                    M_w[`M00] = $signed(M_r[`M00]) - $signed(mul0_ans);
                    mul1_a   = div1_ans;
                    mul1_b   = M_r[`M01];
                    M_w[`M08] = $signed(M_r[`M08]) - $signed(mul1_ans);

                    // row2
                    M_w[`M21] = 0;
                    mul2_a   = div0_ans;
                    mul2_b   = M_r[`M21];
                    M_w[`M20] = $signed(M_r[`M20]) - $signed(mul2_ans);
                    mul3_a   = div1_ans;
                    mul3_b   = M_r[`M21];
                    M_w[`M28] = $signed(M_r[`M28]) - $signed(mul3_ans);
                    
                    // row3
                    M_w[`M31] = 0;
                    mul4_a   = div0_ans;
                    mul4_b   = M_r[`M31];
                    M_w[`M30] = $signed(M_r[`M30]) - $signed(mul4_ans);
                    mul5_a   = div1_ans;
                    mul5_b   = M_r[`M31];
                    M_w[`M38] = $signed(M_r[`M38]) - $signed(mul5_ans);
                end 
                1: begin
                    // row7
                    M_w[`M74] = 8192;
                    div0_a = M_r[`M73];
                    div0_b = M_r[`M74];
                    M_w[`M73] = div0_ans;

                    div1_a   = M_r[`M78];
                    div1_b   = M_r[`M74];
                    M_w[`M78] = div1_ans;
                    
                    // row4
                    M_w[`M44] = 0;
                    mul0_a   = div0_ans;
                    mul0_b   = M_r[`M44];
                    M_w[`M43] = $signed(M_r[`M43]) - $signed(mul0_ans);
                    mul1_a   = div1_ans;
                    mul1_b   = M_r[`M44];
                    M_w[`M48] = $signed(M_r[`M48]) - $signed(mul1_ans);

                    // row5
                    M_w[`M54] = 0;
                    mul2_a   = div0_ans;
                    mul2_b   = M_r[`M54];
                    M_w[`M53] = $signed(M_r[`M53]) - $signed(mul2_ans);
                    mul3_a   = div1_ans;
                    mul3_b   = M_r[`M54];
                    M_w[`M58] = $signed(M_r[`M58]) - $signed(mul3_ans);
                    
                    // row6
                    M_w[`M64] = 0;
                    mul4_a   = div0_ans;
                    mul4_b   = M_r[`M64];
                    M_w[`M63] = $signed(M_r[`M63]) - $signed(mul4_ans);
                    mul5_a   = div1_ans;
                    mul5_b   = M_r[`M64];
                    M_w[`M68] = $signed(M_r[`M68]) - $signed(mul5_ans);
                end
                2: begin
                    // row2
                    M_w[`M20] = 8192;
                    div0_a   = M_r[`M26];
                    div0_b   = M_r[`M20];
                    M_w[`M26] = div0_ans;
                    div1_a   = M_r[`M27];
                    div1_b   = M_r[`M20];
                    M_w[`M27] = div1_ans;
                    div2_a   = M_r[`M28];
                    div2_b   = M_r[`M20];
                    M_w[`M28] = div2_ans;

                    // row3
                    M_w[`M30] = 0;
                    mul0_a   = div0_ans;
                    mul0_b   = M_r[`M30];
                    M_w[`M36] = $signed(M_w[`M36]) - $signed(mul0_ans);
                    mul1_a   = div1_ans;
                    mul1_b   = M_r[`M30];
                    M_w[`M37] = $signed(M_w[`M37]) - $signed(mul1_ans);
                    mul2_a   = div2_ans;
                    mul2_b   = M_r[`M30];
                    M_w[`M38] = $signed(M_w[`M38]) - $signed(mul2_ans);
                end
                3: begin
                    // row5
                    M_w[`M53] = 8192;
                    div0_a = M_r[`M56];
                    div0_b = M_r[`M53];
                    M_w[`M56] = div0_ans;
                    div1_a = M_r[`M57];
                    div1_b = M_r[`M53];
                    M_w[`M57] = div1_ans;
                    div2_a = M_r[`M58];
                    div2_b = M_r[`M53];
                    M_w[`M58] = div2_ans;

                    // row6
                    M_w[`M63] = 0;
                    mul0_a   = div0_ans;
                    mul0_b   = M_r[`M63];
                    M_w[`M66] = $signed(M_w[`M66]) - $signed(mul0_ans);
                    mul1_a   = div1_ans;
                    mul1_b   = M_r[`M63];
                    M_w[`M67] = $signed(M_w[`M67]) - $signed(mul1_ans);
                    mul2_a   = div2_ans;
                    mul2_b   = M_r[`M63];
                    M_w[`M68] = $signed(M_w[`M68]) - $signed(mul2_ans);
                end
                4: begin
                    // row6
                    M_w[`M66] = 8192;
                    div0_a = M_r[`M67];
                    div0_b = M_r[`M66];
                    M_w[`M67] = div0_ans;
                    div1_a = M_r[`M68];
                    div1_b = M_r[`M66];
                    M_w[`M68] = div1_ans;

                    // row2
                    M_w[`M26] = 0;
                    mul0_a = M_r[`M26];
                    mul0_b = div0_ans;
                    M_w[`M27] = $signed(M_w[`M27]) - $signed(mul0_ans);
                    mul1_a = M_r[`M26];
                    mul1_b = div1_ans;
                    M_w[`M28] = $signed(M_w[`M28]) - $signed(mul1_ans);

                    // row3
                    M_w[`M36] = 0;
                    mul2_a = M_r[`M36];
                    mul2_b = div0_ans;
                    M_w[`M37] = $signed(M_w[`M37]) - $signed(mul2_ans);
                    mul3_a = M_r[`M36];
                    mul3_b = div1_ans;
                    M_w[`M38] = $signed(M_w[`M38]) - $signed(mul3_ans);

                    // row5
                    M_w[`M56] = 0;
                    mul4_a = M_r[`M56];
                    mul4_b = div0_ans;
                    M_w[`M57] = $signed(M_w[`M57]) - $signed(mul4_ans);
                    mul5_a = M_r[`M56];
                    mul5_b = div1_ans;
                    M_w[`M58] = $signed(M_w[`M58]) - $signed(mul5_ans);
                end
                5: begin
                    // row3
                    M_w[`M37] = 8192;
                    div0_a = M_r[`M38];
                    div0_b = M_r[`M37];
                    M_w[`M38] = div0_ans;

                    // row2
                    M_w[`M27] = 0;
                    mul0_a = div0_ans;
                    mul0_b = M_r[`M27];
                    M_w[`M28] = M_r[`M28] - mul0_ans;

                    // row5
                    M_w[`M57] = 0;
                    mul1_a = div0_ans;
                    mul1_b = M_r[`M57];
                    M_w[`M58] = M_r[`M58] - mul1_ans;

                    // row6
                    M_w[`M67] = 0;
                    mul2_a = div0_ans;
                    mul2_b = M_r[`M67];
                    M_w[`M68] = M_r[`M68] - mul2_ans;
                end
                6: begin
                    // row0
                    mul0_a = M_r[`M00];
                    mul0_b = M_r[`M28];
                    M_w[`M08] = M_r[`M08] - mul0_ans;

                    // row1
                    mul1_a = M_r[`M10];
                    mul1_b = M_r[`M28];
                    M_w[`M18] = M_r[`M18] - mul1_ans;

                    // row4
                    mul2_a = M_r[`M43];
                    mul2_b = M_r[`M58];
                    M_w[`M48] = M_r[`M48] - mul2_ans;
                    
                    // row7
                    mul3_a = M_r[`M73];
                    mul3_b = M_r[`M58];
                    M_w[`M78] = M_r[`M78] - mul3_ans;
                end
                7: begin
                    matrix_w[0] = M_r[`M28];    // A
                    matrix_w[1] = M_r[`M18];    // B
                    matrix_w[2] = M_r[`M08];    // C
                    matrix_w[3] = M_r[`M58];    // D
                    matrix_w[4] = M_r[`M78];    // E 
                    matrix_w[5] = M_r[`M48];    // F 
                    matrix_w[6] = M_r[`M68];    // G
                    matrix_w[7] = M_r[`M38];    // H
                    valid_w     = 1;
                    counter_w   = 0;
                end
                default: begin
                    valid_w = 0;
                    for (integer i = 0;i < 32;i = i + 1) begin
                        M_w[i] = M_r[i];
                    end
                    counter_w = counter_r + 1;
                end
            endcase
        end
        default: begin
            valid_w = 0;
            for (integer i = 0;i < 32;i = i + 1) begin
                M_w[i] = M_r[i];
            end
            counter_w = counter_r + 1;
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r <= 0;
        counter_r <= 0;
        for (integer i = 0;i < 32;i = i + 1) begin
            M_r[i] <= 0;
        end
        valid_r <= 0;
        for (integer i = 0;i < 8;i = i + 1) begin
            matrix_r[i] <= 0;
        end
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
        for (integer i = 0;i < 32;i = i + 1) begin
            M_r[i] <= M_w[i];
        end
        valid_r <= valid_w;
        for (integer i = 0;i < 8;i = i + 1) begin
            matrix_r <= matrix_w;
        end
    end
end
endmodule


module mul #(
    parameter INT_W  = 20,
    parameter FRAC_W = 13
)(
    input  [INT_W + FRAC_W - 1: 0] A,
    input  [INT_W + FRAC_W - 1: 0] B,
    output [INT_W + FRAC_W - 1: 0] ANS
);
    localparam WIDTH = INT_W + FRAC_W;
    localparam MAX = {1'b0, {(WIDTH-1){1'b1}}};
    localparam MIN = {1'b1, {(WIDTH-1){1'b0}}};
    logic overflow;
    logic [2 * WIDTH - 1:0] mul_result;
    assign mul_result = $signed(A) * $signed(B);
    assign ANS = overflow ? ((A[WIDTH - 1] ^ B[WIDTH - 1])? MIN : MAX): mul_result[WIDTH + FRAC_W - 1:FRAC_W];
    always_comb begin
        if (&(mul_result[2*WIDTH-1 -: (INT_W+1)]) || !(mul_result[2*WIDTH-1 -: (INT_W+1)])) begin
            overflow = 0;
        end
        else overflow = 1;
    end
endmodule

module div #(
    parameter INT_W = 20, 
    parameter FRAC_W = 13
) (
    input  [INT_W + FRAC_W - 1: 0] A,
    input  [INT_W + FRAC_W - 1: 0] B,
    output [INT_W + FRAC_W - 1: 0] ANS
);
    localparam WIDTH = INT_W + FRAC_W;
    localparam MAX = {1'b0, {(WIDTH-1){1'b1}}};
    localparam MIN = {1'b1, {(WIDTH-1){1'b0}}};
    logic overflow;
    logic [WIDTH + FRAC_W - 1:0] div_result;
    assign div_result = $signed({A, {FRAC_W{1'b0}}}) / $signed(B);
    assign ANS = overflow ? (A[WIDTH - 1] ^ B[WIDTH - 1])? MIN : MAX: div_result[WIDTH - 1: 0];
    always_comb begin
        if (&(div_result[WIDTH + FRAC_W - 1 -: (FRAC_W+1)]) || !(div_result[WIDTH + FRAC_W - 1 -: (FRAC_W+1)])) begin
            overflow = 0;
        end
        else overflow = 1;
    end
endmodule