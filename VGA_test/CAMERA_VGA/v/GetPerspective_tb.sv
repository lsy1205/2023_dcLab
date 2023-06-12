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
    .i_ul_addr({10'd23, 10'd63}), // first 10 bit is x, last is y
    .i_ur_addr({10'd698, 10'd11}),
    .i_dr_addr({10'd788, 10'd520}),
    .i_dl_addr({10'd40, 10'd499}),

    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .E(E),
    .F(F),
    .G(G),
    .H(H),
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