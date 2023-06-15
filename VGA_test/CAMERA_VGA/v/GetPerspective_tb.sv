`timescale 1ns/1ps

module test ();
logic clk = 0;
logic rst_n = 1;
logic start = 0;
logic [32:0] A, B, C, D, E, F, G, H;
logic valid;
always #5 clk = ~clk;

initial begin
    #1  rst_n = 0;
    #17 rst_n = 1;

    @(posedge clk) start = 1;
    @(posedge clk) start = 0;
end

// p = np.array([(23, 63), (40, 499), (788, 520), (698, 11)])

initial begin
    $fsdbDumpfile("inverse.fsdb");
    $fsdbDumpvars(0, "+mda");
    // $fsdbDumpvars;
end

GetPerspective M0 (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_ul_addr({10'd310, 10'd63}), // first 10 bit is x, last is y
    .i_ur_addr({10'd500, 10'd18}),
    .i_dr_addr({10'd400, 10'd190}),
    .i_dl_addr({10'd290, 10'd220}),
    
    // .i_ul_addr({10'd120, 10'd20}), // first 10 bit is x, last is y
    // .i_dl_addr({10'd23, 10'd523}),
    // .i_dr_addr({10'd677, 10'd499}),
    // .i_ur_addr({10'd499, 10'd18}),

    .o_A(A),
    .o_B(B),
    .o_C(C),
    .o_D(D),
    .o_E(E),
    .o_F(F),
    .o_G(G),
    .o_H(H),
    .o_valid(valid)
);

always @(*) begin
    if (valid) begin
        $display("%d", $signed(A));
        $display("%d", $signed(B));
        $display("%d", $signed(C));
        $display("%d", $signed(D));
        $display("%d", $signed(E));
        $display("%d", $signed(F));
        $display("%d", $signed(G));
        $display("%d", $signed(H));
        #10 $finish;
    end
end
endmodule

module lpm_divide (
    input aclr,
    input clken,
    input clock,
    input [39:0] denom,
    input [47:0] numer,
    output [47:0] quotient,
    output [47:0] remain
);

parameter lpm_drepresentation = "SIGNED";
parameter lpm_hint = "MAXIMIZE_SPEED=6,LPM_REMAINDERPOSITIVE=FALSE";
parameter lpm_nrepresentation = "SIGNED";
parameter lpm_pipeline = 16;
parameter lpm_type = "LPM_DIVIDE";
parameter lpm_widthd = 40;
parameter lpm_widthn = 48;

logic [47:0] q_r[0:15], q_w[0:15];

assign quotient = q_r[15];

always_comb begin
    for (integer i = 1; i < 16; i=i+1) begin
        q_w[i] = q_r[i-1];
    end
    q_w[0] = $signed(numer) / $signed(denom);
end

always_ff @(posedge clock) begin
    for (integer i = 0; i < 16; i=i+1) begin
        q_r[i] <= q_w[i];
    end
end
    
endmodule
