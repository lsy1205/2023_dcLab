`timescale 1ns/100ps

module tb;

logic        rst_n;
logic        CLK_50M, CLK_12M, CLK_800K, CLK_100K;
wire   [3:0] num;
wire   [7:0] LCD_DATA;
wire   [8:0] LEDG;
wire  [17:0] LEDR;


Top top0 (
	.i_rst_n(rst_n),
	.i_clk(CLK_50M),
	
	// SEVENDECODER (optional display)
	.o_display(num),

	// LCD (optional display)
	.i_clk_50(CLK_50M),
	.io_LCD_DATA(LCD_DATA), // [7:0]
	.o_LCD_EN(LCD_EN),
	.o_LCD_RS(LCD_RS),
	.o_LCD_RW(LCD_RW),
	.o_LCD_ON(LCD_ON),
	.o_LCD_BLON(LCD_BLON),

	// LED
	.o_ledg(LEDG), // [8:0]
	.o_ledr(LEDR) // [17:0]
);

initial begin
    $fsdbDumpfile("Top.fsdb");
    $fsdbDumpvars;

    rst_n    = 1;
	CLK_50M  = 0;
    CLK_12M  = 0;
    CLK_800K = 0;
    CLK_100K = 0;

    #10  rst_n = 0;
    #100 rst_n = 1;
end

always #(   20/2) CLK_50M  = ~CLK_50M;
always #(   84/2) CLK_12M  = ~CLK_12M;
always #( 1250/2) CLK_800K = ~CLK_800K;
always #(10000/2) CLK_100K = ~CLK_100K;

initial begin
    #(250000)
    $finish;
end

endmodule
