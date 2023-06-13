module PerspectiveTransformer #(
    parameter INT_W  = 20,
    parameter FRAC_W = 13
) (
    input                         i_clk,
    input                         i_rst_n,
    input                         i_start,
    input  [                19:0] i_pixel,
    input  [INT_W + FRAC_W - 1:0] i_A,
    input  [INT_W + FRAC_W - 1:0] i_B,
    input  [INT_W + FRAC_W - 1:0] i_C,
    input  [INT_W + FRAC_W - 1:0] i_D,
    input  [INT_W + FRAC_W - 1:0] i_E,
    input  [INT_W + FRAC_W - 1:0] i_F,
    input  [INT_W + FRAC_W - 1:0] i_G,
    input  [INT_W + FRAC_W - 1:0] i_H,

    output                        o_inside,
    output [                13:0] o_point
);

localparam WIDTH = INT_W + FRAC_W;

logic processing_r, processing_w;
logic [WIDTH - 1:0] mul0_a, mul0_b, mul1_a, mul1_b, mul2_a, mul2_b;
logic [WIDTH - 1:0] mul3_a, mul3_b, mul4_a, mul4_b, mul5_a, mul5_b;
logic [WIDTH - 1:0] mul0_ans, mul1_ans, mul2_ans, mul3_ans, mul4_ans, mul5_ans;

logic [WIDTH + 1:0] div0_a, div0_b, div1_a, div1_b;
logic [WIDTH + 1:0] div0_ans, div1_ans;
logic [       13:0] point_r, point_w;
logic               inside_r, inside_w;

logic [WIDTH + 1:0] rho, rho_x, rho_y;

logic               out;

assign out = $signed(div0_ans[WIDTH+1]) || $signed(div0_ans[WIDTH - 1:FRAC_W]) > 99 || $signed(div1_ans[WIDTH+1]) || $signed(div1_ans[WIDTH - 1:FRAC_W]) > 99;
assign o_point = point_r;
assign o_inside = inside_r;

mul mul0(
    .A(mul0_a),
    .B(mul0_b),
    .ANS(mul0_ans)
);
mul mul1(
    .A(mul1_a),
    .B(mul1_b),
    .ANS(mul1_ans)
);
mul mul2(
    .A(mul2_a),
    .B(mul2_b),
    .ANS(mul2_ans)
);
mul mul3(
    .A(mul3_a),
    .B(mul3_b),
    .ANS(mul3_ans)
);
mul mul4(
    .A(mul4_a),
    .B(mul4_b),
    .ANS(mul4_ans)
);
mul mul5(
    .A(mul5_a),
    .B(mul5_b),
    .ANS(mul5_ans)
);
div div0(
    .A(div0_a),
    .B(div0_b),
    .ANS(div0_ans)
);
div div1(
    .A(div1_a),
    .B(div1_b),
    .ANS(div1_ans)
);

always_comb begin
    processing_w = processing_r;
    mul0_a   = 0;
    mul0_b   = 0;
    mul1_a   = 0;
    mul1_b   = 0;
    mul2_a   = 0;
    mul2_b   = 0;
    mul3_a   = 0;
    mul3_b   = 0;
    mul4_a   = 0;
    mul4_b   = 0;
    mul5_a   = 0;
    mul5_b   = 0;
    rho_x    = 0;
    rho_y    = 0;
    rho      = 0;
    div0_a   = 0;
    div0_b   = 0;
    div1_a   = 0;
    div1_b   = 0;
    inside_w = ~out;
    point_w  = 0;
    case (processing_r)
        0: begin
            if (i_start) begin
                processing_w = ~processing_r;
                mul0_a = i_pixel[19:10];
                mul0_b = i_A;
                mul1_a = i_pixel[ 9: 0];
                mul1_b = i_B;
                mul2_a = i_pixel[19:10];
                mul2_b = i_D;
                mul3_a = i_pixel[ 9: 0];
                mul3_b = i_E;
                mul4_a = i_pixel[19:10];
                mul4_b = i_G;
                mul5_a = i_pixel[ 9: 0];
                mul5_b = i_H;
                rho_x  = $signed(mul0_ans) + $signed(mul1_ans) + $signed(i_C);
                rho_y  = $signed(mul2_ans) + $signed(mul3_ans) + $signed(i_F);
                rho    = $signed(mul4_ans) + $signed(mul5_ans) + $signed(33'd8192);
                div0_a = rho_x;
                div0_b = rho;
                div1_a = rho_y;
                div1_b = rho;
                point_w = {div0_ans[FRAC_W + 6:FRAC_W] + div0_ans[FRAC_W - 1], div1_ans[FRAC_W + 6:FRAC_W] + div1_ans[FRAC_W - 1]};
            end
        end 
        1: begin
            processing_w = ~processing_r;
        end
        default: begin
            processing_w = 0;
            mul0_b   = 0;
            mul0_a   = 0;
            mul1_a   = 0;
            mul1_b   = 0;
            mul2_a   = 0;
            mul2_b   = 0;
            mul3_a   = 0;
            mul3_b   = 0;
            mul4_a   = 0;
            mul4_b   = 0;
            mul5_a   = 0;
            mul5_b   = 0;
            rho_x    = 0;
            rho_y    = 0;
            rho      = 0;
            div0_a   = 0;
            div0_b   = 0;
            div1_a   = 0;
            div1_b   = 0;
            inside_w = 0;
            point_w  = 0;
        end
    endcase
end
    
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        processing_r <= 0;
        point_r <= 0;
        inside_r <= 0;
    end
    else begin
        processing_r <= processing_w;
        point_r <= point_w;
        inside_r <= inside_w;
    end
end

endmodule

module mul #(
    parameter INT_W  = 20,
    parameter FRAC_W = 13
)(
    input  [INT_W - 1: 0] A,
    input  [INT_W + FRAC_W - 1: 0] B,
    output [INT_W + FRAC_W - 1: 0] ANS
);
    localparam WIDTH = INT_W + FRAC_W;
    localparam MAX = {1'b0, {(WIDTH-1){1'b1}}};
    localparam MIN = {1'b1, {(WIDTH-1){1'b0}}};
    logic overflow;
    logic [WIDTH + FRAC_W - 1:0] mul_result;
    assign mul_result = $signed(A) * $signed(B);
    assign ANS = overflow ? ((A[INT_W - 1] ^ B[WIDTH - 1])? MIN : MAX): mul_result[WIDTH - 1 : 0];
    always_comb begin
        if (&(mul_result[WIDTH + FRAC_W - 1 -: INT_W + 1]) || !(mul_result[WIDTH + FRAC_W - 1 -: INT_W + 1])) 
            overflow = 0;
        else
            overflow = 1;
    end
endmodule

module div #(
    parameter INT_W = 20, 
    parameter FRAC_W = 13
) (
    input  [INT_W + FRAC_W + 1: 0] A,
    input  [INT_W + FRAC_W + 1: 0] B,
    output [INT_W + FRAC_W + 1: 0] ANS
);
    localparam WIDTH = INT_W + FRAC_W + 1;
    localparam MAX = {1'b0, {(WIDTH + 1){1'b1}}};
    localparam MIN = {1'b1, {(WIDTH + 1){1'b0}}};
    logic      overflow;
    logic [WIDTH + FRAC_W + 1:0] div_result;
    assign div_result = $signed({A, {FRAC_W{1'b0}}}) / $signed(B);
    assign ANS = overflow ? (A[WIDTH - 1] ^ B[WIDTH - 1])? MIN : MAX: div_result[WIDTH - 1: 0];
    always_comb begin
        if (&(div_result[WIDTH + FRAC_W - 1 -: (FRAC_W+1)]) || !(div_result[WIDTH + FRAC_W - 1 -: (FRAC_W+1)])) begin
            overflow = 0;
        end
        else overflow = 1;
    end
endmodule