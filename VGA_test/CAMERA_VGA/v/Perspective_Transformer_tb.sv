`timescale 1ns/1ps
module test ();
logic clk = 0;
logic rst_n = 1;
logic start = 0;
logic [13:0] point;
logic is_inside;

always #5 clk = ~clk;
    
initial begin
    $fsdbDumpfile("transform.fsdb");
    $fsdbDumpvars(0, "+mda");
end

PerspectiveTransformer #(
    .INT_W(20),
    .FRAC_W(13)
)p0(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_pixel({10'd300, 10'd300}),
    .i_A(1269),
    .i_B(-49),
    .i_C(-26073),
    .i_D(152),
    .i_E(1974),
    .i_F(-127800),
    .i_G(2),
    .i_H(1),
    .o_inside(is_inside),
    .o_point(point)
);

initial begin
    #1  rst_n = 0;
    #17 rst_n = 1;

    @(posedge clk) start = 1;
    @(posedge clk) start = 0; 
    #10;
    $display("%d", $signed(point[13:7]));
    $display("%d", $signed(point[ 6:0]));
    #10$finish;
end
    
endmodule