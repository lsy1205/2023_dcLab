`timescale 1ns/100ps
module test ();
logic clk = 0;
logic rst_n = 1;
logic start = 0;
logic [13:0] point;
logic is_inside;

always #1 clk = ~clk;
    
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
    .i_A(3684),
    .i_B(470),
    .i_C(-1171618),
    .i_D(610),
    .i_E(2576),
    .i_F(-351362),
    .i_G(-4),
    .i_H(-17),
    .o_inside(is_inside),
    .o_point(point),
    .i_req(1'b1)
);

initial begin
    #1  rst_n = 0;
    #7  rst_n = 1;

    @(posedge clk) start = 1;
    @(posedge clk) start = 0; 
    #10;
    $display("%d", $signed(point[13:7]));
    $display("%d", $signed(point[ 6:0]));
    #100000000$finish;
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
