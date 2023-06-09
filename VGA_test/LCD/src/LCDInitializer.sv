module LCDInitializer (
    input        i_clk,
    input        i_rst_n,
	output       o_fin,

    inout  [7:0] io_LCD_DATA,
    output       o_LCD_EN,
    output       o_LCD_RS,
    output       o_LCD_RW,
    output       o_LCD_ON,
    output       o_LCD_BLON
);

// INITIALIZE
localparam INSTRUCT_0 = 10'b00_0011_1000; // Fun Set 
localparam INSTRUCT_1 = 10'b00_0000_1100; // Dis on
localparam INSTRUCT_2 = 10'b00_0000_0001; // Clr dis
localparam INSTRUCT_3 = 10'b00_0000_0110; // Ent mode
localparam INSTRUCT_4 = 10'b00_1000_0000; // Ddram 00

localparam WAIT      = 15360;

// STATE
localparam S_IDLE     = 0;  
localparam S_INIT     = 1;  // init LCD
localparam S_BF       = 2;  // check busy flag
localparam S_SHIFT    = 3;  // shift cursor
localparam S_WRITE    = 4;  // write display data
localparam S_WAIT     = 5;	// wait new display


// INSTRUCTION SET (AC-address counter)
localparam CLEAR    = 10'b00_0000_0001;
	// DDRAM 設為00H，光標回到起始位置，AC 設為0
localparam RETURN   = 10'b00_0000_0010;
	// 光標回到起始位置，AC放0，DDRAM 內容不變
localparam MODE_SET = 10'b00_0000_0110; 
	// DB1: 0-left shift（光標） , DB0: 0-屏不動 1-屏右移（屏幕？）
localparam DISPLAY  = 10'b00_0000_1100;
	// DB2: 0-顯示屏關 1-顯示屏開, DB1: 0-無光標 1-有光標, DB0: 0-光標閃 1-光標不閃
localparam CURSOR_DISPLAY_SHIFT = 10'b00_0001_0100;
	// DB3: S/C, DB2: R/L -> 00光標左移 AC-1, 01光標右移 AC+1, 10顯示屏所有字符左移一格光標不動, 11顯示屏所有字符右移一格光標不動
localparam FUNC_SET  = 10'b00_0011_1000;
	// DB4: 0-4bit 1-8bit, DB3: 0-一行 1-兩行,DB2: 0- 5*8 dots 1- 5*11 dots
localparam CGRAM = 4'b00_01;
	// 設置後面加 6bit CGRAM address，AC 設為CGRAM address
localparam DDRAM = 3'b00_1;
	// 後面加 7bit DDRAM address，AC 設為DDRAM address
localparam BUSY = 2'b01;
	// 後面加 BF + 7bit address
localparam WRITE_DATA = 2'b10;
	// 後面 8bit 資訊寫入 AC 位址（顯示字寫入DDRAM並顯示，自定義圖形存入CGRAM）
localparam READ_DATA = 2'b11;
	// 後面 8bit 為讀取 AC 位址資訊

// == regs and wires  == //
always_comb begin: FSM 
	state_w = state_r;
	case (state_r)	
		S_IDLE: begin
			
		end 
		default: begin
			
		end
	endcase
end

always_comb begin
	
end


always_ff @(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) begin
		
	end
	else begin
		
	end
end
endmodule
