module MUL #(
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
logic [2*WIDTH - 1:0] mul_result;

assign mul_result = $signed(A) * $signed(B);
assign ANS = overflow ? ((A[WIDTH-1] ^ B[WIDTH-1]) ? MIN : MAX) :
                        mul_result[WIDTH + FRAC_W - 1:FRAC_W];

always_comb begin
    if (&(mul_result[2*WIDTH-1 -: (INT_W+1)]) || !(mul_result[2*WIDTH-1 -: (INT_W+1)])) begin
        overflow = 0;
    end
    else begin
        overflow = 1;
    end
end

endmodule


module DIV #(
    parameter INT_W = 20, 
    parameter FRAC_W = 13
) (
    input  i_clk,
    input  i_rst_n,
    input  i_clken,
    input  [INT_W + FRAC_W - 1: 0] A,
    input  [INT_W + FRAC_W - 1: 0] B,
    output [INT_W + FRAC_W - 1: 0] ANS
);

localparam WIDTH = INT_W + FRAC_W;
localparam MAX = {1'b0, {(WIDTH-1){1'b1}}};
localparam MIN = {1'b1, {(WIDTH-1){1'b0}}};

logic overflow;
logic [WIDTH + FRAC_W - 1:0] div_result;

assign ANS = overflow ? ((A[WIDTH-1] ^ B[WIDTH-1]) ? MIN : MAX) :
                        div_result[WIDTH-1: 0];

Div div_Div_0 (
    clock(i_clk),
    aclr(~i_rst_n),
    clken(i_clken),
    numer(A << FRAC_W),
    denom(B),
    quotient(div_result)
);
    
always_comb begin
    if (&(div_result[WIDTH+FRAC_W-1 -: (FRAC_W+1)]) || !(div_result[WIDTH+FRAC_W-1 -: (FRAC_W+1)])) begin
        overflow = 0;
    end
    else begin
        overflow = 1;
    end
end

endmodule
