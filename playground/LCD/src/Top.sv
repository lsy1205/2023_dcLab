module Top (
	input        i_rst_n,
	input        i_clk,

	// SEVENDECODER (optional display)
	output       o_display,

	// LCD (optional display)
	input        i_clk_50,
	inout  [7:0] io_LCD_DATA, // [7:0]
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW,
	output       o_LCD_ON,
	output       o_LCD_BLON,

	// LED
	output  [8:0] o_ledg, // [8:0]
	output [17:0] o_ledr  // [17:0]
);

assign o_ledg = 0;
assign o_ledr = 0;
assign o_display = state_r;

localparam S_IDLE = 0;
localparam S_INIT = 1;
localparam S_SHOW = 2;

logic       lcd_init_start_r, lcd_init_start_w;
logic       lcd_init_fin;
logic [1:0] state_r, state_w;

always_comb begin:FSM
	case (state_r)
		S_IDLE: begin
			state_w = S_INIT;
		end 
		S_INIT: begin
			// state_w = (lcd_init_fin) ? S_SHOW : S_INIT; 
			state_w = S_INIT;
		end
		S_SHOW: begin
			state_w = S_SHOW;
		end
		default: begin
			
		end
	endcase
end

always_comb begin
	lcd_init_start_w = 0;
	case (state_r)
		S_IDLE: begin
			lcd_init_start_w = 1;
		end 
		S_INIT: begin
			lcd_init_start_w = 0;
		end
		S_SHOW: begin

		end
		default: begin
			
		end
	endcase
end


always_ff @( posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		state_r <= 0;
		lcd_init_start_r <= 0;

	end
	else begin
		state_r <= state_w;
		lcd_init_start_r <= lcd_init_start_w;
	end
end


// LCDInitializer LCDInit0(
// 	.i_clk(i_clk_800k),
//     .i_rst_n(i_rst_n),
// 	.o_fin(lcd_init_fin),

// 	.io_LCD_DATA(io_LCD_DATA),
// 	.o_LCD_EN(o_LCD_EN),
// 	.o_LCD_RS(o_LCD_RS),
// 	.o_LCD_RW(LCD_RW),
// 	.o_LCD_ON(o_LCD_ON),
// 	.o_LCD_BLON(o_LCD_BLON)
// );


LCD_top LCD_top0(
    .CLOCK_50(i_clk_50),   
    .LCD_ON(o_LCD_ON),     
    .LCD_BLON(o_LCD_BLON),   
    .LCD_RW(o_LCD_RW),     
    .LCD_EN(o_LCD_EN),     
    .LCD_RS(o_LCD_RS),     
    .LCD_DATA(io_LCD_DATA)    
);
             

endmodule