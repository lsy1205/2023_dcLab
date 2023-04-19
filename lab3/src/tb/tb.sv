`timescale 1ns/100ps

module tb(
	inout [15:0] SRAM_DQ
)
;

logic        rst_n;
logic        CLK_12M, CLK_100K, CLK_800K, AUD_BCLK;
logic        AUD_ADCLRCK, AUD_DACLRCK;
logic        data_bit;
logic [15:0] data;
wire  [19:0] SRAM_ADDR;
wire   [3:0] seg7, speed;
wire   [7:0] LCD_DATA;
wire   [8:0] LEDG;
wire  [17:0] LEDR;
logic        key0, key1, key2, key3, start;
logic        sw0, sw1;


Top top0 (
	.i_rst_n(rst_n),
	.i_clk(CLK_12M),
	.i_sw_0(sw0level),  // Play=0/Record=1 mode
	.i_sw_1(sw1level),  // 0/1 order interpolation
	.i_key_0(key0down | start), // Start/Pause
	.i_key_1(key1down), // Stop
	.i_key_2(key2down), // Speed up
	.i_key_3(key3down), // Speed down
	
	// AudDSP and SRAM
	.o_SRAM_ADDR(SRAM_ADDR), // [19:0]
	.io_SRAM_DQ(SRAM_DQ), // [15:0]
	.o_SRAM_WE_N(SRAM_WE_N),
	.o_SRAM_CE_N(SRAM_CE_N),
	.o_SRAM_OE_N(SRAM_OE_N),
	.o_SRAM_LB_N(SRAM_LB_N),
	.o_SRAM_UB_N(SRAM_UB_N),
	
	// I2C
	.i_clk_100k(CLK_100K),
	.o_I2C_SCLK(I2C_SCLK),
	.io_I2C_SDAT(I2C_SDAT),
	
	// I2S
	.i_AUD_BCLK(AUD_BCLK),
	.i_AUD_ADCLRCK(AUD_ADCLRCK),
	.i_AUD_ADCDAT(AUD_ADCDAT),
	.i_AUD_DACLRCK(AUD_DACLRCK),
	.o_AUD_DACDAT(AUD_DACDAT),

	// SEVENDECODER (optional display)
	.o_speed(speed),
	.o_seg7(seg7),

	// LCD (optional display)
	.i_clk_800k(CLK_800K),
	.o_LCD_DATA(LCD_DATA), // [7:0]
	.o_LCD_EN(LCD_EN),
	.o_LCD_RS(LCD_RS),
	.o_LCD_RW(LCD_RW),
	.o_LCD_ON(LCD_ON),
	.o_LCD_BLON(LCD_BLON),

	// LED
	.o_ledg(LEDG), // [8:0]
	.o_ledr(LEDR) // [17:0]
);

assign key0down   = key0;
assign key1down   = key1;
assign key2down   = key2;
assign key3down   = key3;
assign AUD_ADCDAT = data_bit;
assign SRAM_DQ    = (!sw0) ? data : 16'bz;

assign sw0level = sw0;
assign sw1level = 1;

initial begin
	sw0 = 1;
	#(30000000)
	sw0 = 0;
end

initial begin
    $fsdbDumpfile("Top.fsdb");
    $fsdbDumpvars;

    rst_n    = 1;
    CLK_12M  = 0;
    CLK_100K = 0;
    CLK_800K = 0;
    AUD_BCLK = 1;
	AUD_ADCLRCK = 0;
	AUD_DACLRCK = 0;
	start = 0;

    #10  rst_n = 0;
    #100 rst_n = 1;
end

always_ff @(posedge CLK_12M) begin
	key0 = ($random() % 10000) == 1532;
	key1 = ($random() % 10000) == 7689;
	key2 = ($random() % 10000) == 5443;
	key3 = 0;//($random() % 10000) == 1457;
end

always @(SRAM_ADDR) data = $random();
always @(negedge AUD_BCLK) data_bit = $random(); 

always @(seg7[2:0]) begin
	if (seg7[2:0] == 2 || seg7[2:0] == 6) begin
		#(1000)
		@(negedge CLK_12M)
		start = 1;
		@(negedge CLK_12M)
		start = 0;
	end
end

always #(   84/2) CLK_12M  = ~CLK_12M;
always #(10000/2) CLK_100K = ~CLK_100K;
always #( 1250/2) CLK_800K = ~CLK_800K;
always #(   84/2) AUD_BCLK = ~AUD_BCLK;
always #(31250/2) AUD_ADCLRCK = ~AUD_ADCLRCK;
always #(31250/2) AUD_DACLRCK = ~AUD_DACLRCK;

initial begin
    #(60000000)
    $finish;
end

endmodule
