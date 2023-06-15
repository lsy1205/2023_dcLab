module PerspectiveTransformer #(
    parameter FRAC_W = 13
) (
    input         i_clk,
    input         i_rst_n,
    input         i_start,
    input  [35:0] i_A,
    input  [35:0] i_B,
    input  [35:0] i_C,
    input  [35:0] i_D,
    input  [35:0] i_E,
    input  [35:0] i_F,
    input  [35:0] i_G,
    input  [35:0] i_H,

    input         i_req,
    output        o_inside,
    output [13:0] o_point,
    output        o_can_fetch
);


logic [ 9:0] row_counter_r, row_counter_w;
logic [ 9:0] col_counter_r, col_counter_w;
logic        inside_r, inside_w;
logic [13:0] point_r, point_w;
logic        clken;

logic [35:0] A_r, A_w;
logic [35:0] B_r, B_w;
logic [35:0] C_r, C_w;
logic [35:0] D_r, D_w;
logic [35:0] E_r, E_w;
logic [35:0] F_r, F_w;
logic [35:0] G_r, G_w;
logic [35:0] H_r, H_w;

logic [46:0] Ax, By, Dx, Ey, Gx, Hx;
logic [46:0] rho_x, rho_y;
logic [39:0] rho;
logic [47:0] div0_ans, div1_ans;

assign o_inside = inside_r;
assign o_point  = point_r;
assign o_can_fetch = (col_counter_r == 17 && row_counter_r == 0);

// assign clken = i_req || (!col_counter_r[9:4] && row_counter_r == 0); 
assign clken = i_req || (col_counter_r < 17 && row_counter_r == 0); 

assign rho_x = $signed(Ax) + $signed(By) + $signed(C_r);
assign rho_y = $signed(Dx) + $signed(Ey) + $signed(F_r);
assign rho   = $signed(Gx) + $signed(Hx) + ($signed(1) << FRAC_W);

MUL2 mul_0 (
    .A({1'b0, col_counter_r}),
    .B(A_r),
    .ANS(Ax)
);
MUL2 mul_1 (
    .A({1'b0, row_counter_r}),
    .B(B_r),
    .ANS(By)
);
MUL2 mul_2 (
    .A({1'b0, col_counter_r}),
    .B(D_r),
    .ANS(Dx)
);
MUL2 mul_3 (
    .A({1'b0, row_counter_r}),
    .B(E_r),
    .ANS(Ey)
);
MUL2 mul_4 (
    .A({1'b0, col_counter_r}),
    .B(G_r),
    .ANS(Gx)
);
MUL2 mul_5 (
    .A({1'b0, row_counter_r}),
    .B(H_r),
    .ANS(Hx)
);

DIV2 div_0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clken(clken),
    .A(rho_x),
    .B(rho),
    .ANS(div0_ans)
);
DIV2 div_1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clken(clken),
    .A(rho_y),
    .B(rho),
    .ANS(div1_ans)
);

always_comb begin
    inside_w = !(div0_ans[47:7]) && !(div1_ans[47:7]);
    point_w  = {div0_ans[6:0], div1_ans[6:0]};
    col_counter_w = col_counter_r;
    row_counter_w = row_counter_r;
    A_w = A_r;
    B_w = B_r;
    C_w = C_r;
    D_w = D_r;
    E_w = E_r;
    F_w = F_r;
    G_w = G_r;
    H_w = H_r;

    // generate col & row
    if (i_start) begin
        col_counter_w = 0;
        row_counter_w = 0;
        A_w = i_A;
        B_w = i_B;
        C_w = i_C;
        D_w = i_D;
        E_w = i_E;
        F_w = i_F;
        G_w = i_G;
        H_w = i_H;
    end
    
    if (clken && row_counter_r != 600) begin
        if (col_counter_r == 799) begin
            col_counter_w = 0;
            row_counter_w = row_counter_r + 1;
        end
        else begin
            col_counter_w = col_counter_r + 1;
        end
    end
end
    
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r <= 600;
        col_counter_r <= 0;
        inside_r      <= 0;
        point_r       <= 0;
        A_r <= 0;
        B_r <= 0;
        C_r <= 0;
        D_r <= 0;
        E_r <= 0;
        F_r <= 0;
        G_r <= 0;
        H_r <= 0;
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        inside_r      <= inside_w;
        point_r       <= point_w;
        A_r <= A_w;
        B_r <= B_w;
        C_r <= C_w;
        D_r <= D_w;
        E_r <= E_w;
        F_r <= F_w;
        G_r <= G_w;
        H_r <= H_w;
    end
end

endmodule


module MUL2 (
    input  [10:0] A,
    input  [35:0] B,
    output [46:0] ANS
);

localparam MAX = {1'b0, {46{1'b1}}};
localparam MIN = {1'b1, {46{1'b0}}};

logic overflow;
logic [46:0] mul_result;

assign mul_result = $signed(A) * $signed(B);
assign ANS = overflow ? ((B[35]) ? MIN : MAX) :
                        mul_result[46:0];

always_comb begin
    if (&(mul_result[46:35]) || !(mul_result[46:35])) begin
        overflow = 0;
    end
    else begin
        overflow = 1;
    end
end

endmodule


module DIV2 (
    input  i_clk,
    input  i_rst_n,
    input  i_clken,
    input  [46:0] A,
    input  [39:0] B,
    output [47:0] ANS
);


logic [47:0] div_result;

assign ANS = $signed(div_result[47:1]) + $signed({1'b0, div_result[0]});

Div div_Div_0 (
    .clock(i_clk),
    .aclr(~i_rst_n),
    .clken(i_clken),
    .numer({A, 1'b0}),
    .denom(B),
    .quotient(div_result)
);

endmodule
