module LCD (
    input        i_clk,
    input        i_rst_n,
    input        i_start,
	input        i_mode,
    input        i_speed,
	input        i_str,
	input        i_pau,
	input        i_sto,
	output       o_valid,

	inout  [7:0] io_LCD_DATA,
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW
);

// INITIALIZE
localparam INSTRUCT_0 = 10'b000011_0000;
localparam INSTRUCT_1 = 10'b000011_1000;
localparam INSTRUCT_2 = 10'b000000_1100;
localparam INSTRUCT_3 = 10'b000000_0001;
localparam INSTRUCT_4 = 10'b000000_0110;

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

// string
localparam LINE_DEFAULT = "RECPLY STRPAUSTO                ";


// == regs and wires  == //
logic   [2:0] state_r, state_w;
logic   [2:0] init_stage_r, init_stage_w; 

logic  [13:0] counter_r, counter_w;
logic   [7:0] instruct_counter_r, instruct_counter_w; // instruct transmit

logic         mode_now_r, mode_now_w;   // 0: play 1: record
logic   [3:0] speed_now_r, speed_now_w; //  1: 1/8, 2: 1/7, ..., 8: 1, ..., 14: 7, 15: 8
logic   [1:0] control_now_r, control_now_w; // 00:pause 01:start 1x: stop

logic   [9:0] out_r, out_w;
logic [255:0] writedata_r, writedata_w;

assign o_vaild = init_stage_r[2];
assign {o_LCD_RS, o_LCD_RW, io_LCD_DATA} = (state_r == S_BF && state_r == S_WAIT) ? {BUSY, 8'bz} :  out_r;

always_comb begin: FSM 
	state_w = state_r;
	case (state_r) 
	S_IDLE: begin
		if(i_start) state_w = S_INIT;
		else        state_w = S_IDLE;
	end    
	S_INIT: begin
		if(!init_stage_r[2]) state_w = S_INIT;
		else                 state_w = S_BF;
	end    
	S_BF: begin
		if(!io_LCD_DATA[7]) state_w = (!instruct_counter_r[0]) ? S_SHIFT : S_WRITE;
		else                state_w = S_BF;
	end
	S_SHIFT: begin
		state_w = S_BF;
	end
	S_WRITE: begin
		state_w = (!instruct_counter_r[6]) ? S_BF : S_WAIT;
	end
	S_WAIT: begin
		if((mode_now_r == mode_now_w) && (speed_now_r == speed_now_w)) state_w = S_WAIT;
		else state_w = S_BF;
	end
	default: begin
		state_w = S_IDLE;
	end   
	endcase
end

always_comb begin
	mode_now_w         = i_mode;
	speed_now_w        = i_speed;
	control_now_w      = {i_sto, ~i_pau};
	init_stage_w       = init_stage_r;
	writedata_w        = writedata_r;
	counter_w          = counter_r;
	instruct_counter_w = instruct_counter_r;
	out_w              = out_r;

	case (state_r) 
	S_IDLE: begin
		out_w        = INSTRUCT_0;
		init_stage_w = 0;
		writedata_w  = 0;
	end    
	S_INIT: begin
		counter_w = counter_r + 1;
		if (!(counter_r > WAIT)) begin
			out_w = INSTRUCT_0;
		end
		else begin
			case (init_stage_r)
			0: begin
				out_w = INSTRUCT_1;
			end
			1: begin
				out_w = INSTRUCT_2;
			end
			2: begin
				out_w = INSTRUCT_3;
			end
			3: begin
				out_w = INSTRUCT_4;
			end
			4: begin
				instruct_counter_w = 0;
				writedata_w = LINE_DEFAULT;
				case (control_now_r)
				00: begin
					writedata_w[199-:24] = "   ";
					writedata_w[151-:24] = "   ";
				end
				01: writedata_w[175-:48] = "      ";
				10: writedata_w[199-:48] = "      ";
				11: writedata_w[199-:48] = "      ";
				default: begin
					writedata_w = writedata_r;
				end
				endcase
				if(mode_now_w) begin  // record
					writedata_w[231-:24] = "   ";
				end
				else begin  // play
					writedata_w[255-:24] = "   ";
					if(speed_now_r[3]) begin
						writedata_w[71-:8] = "+";
						writedata_w[63-:8] = 8'h30+(speed_now_r-8'h07);
					end
					else begin
						writedata_w[71-:8] = "-";
						writedata_w[63-:8] = 8'h30+(8'h09-speed_now_r);
					end
				end
			end
			default: begin
				out_w = out_r;
			end
			endcase
			init_stage_w = init_stage_r + 1;
		end
	end
	S_BF: begin
		instruct_counter_w = instruct_counter_r + 1;
		if(!instruct_counter_r[0]) begin  // 進 shift
			if(instruct_counter_r == 7'd32) begin
				out_w = {DDRAM, 7'h40};
			end
			else begin
				out_w = {CURSOR_DISPLAY_SHIFT};
			end
		end
		else begin                        // 進 write
			out_w = {WRITE_DATA, writedata_r[255-:8]};
			writedata_w = writedata_r << 8;
		end             
	end
	S_SHIFT: begin
		
	end
	S_WRITE: begin
		
	end
	S_WAIT: begin
		if((mode_now_r != mode_now_w) || (speed_now_r != speed_now_w)) begin
			instruct_counter_w = 0;
			writedata_w = LINE_DEFAULT;
			case (control_now_r)
			00: begin
				writedata_w[199-:24] = "   ";
				writedata_w[151-:24] = "   ";
			end
			01: writedata_w[175-:48] = "      ";
			10: writedata_w[199-:48] = "      ";
			11: writedata_w[199-:48] = "      ";
			default: begin
				writedata_w = writedata_r;
			end
			endcase
			if(mode_now_w) begin  // record
				writedata_w[231-:24] = "   ";
			end
			else begin  // play
				writedata_w[255-:24] = "   ";
				if(speed_now_r[3]) begin
					writedata_w[71-:8] = "+";
					writedata_w[63-:8] = 8'h30+(speed_now_r-8'h07);
				end
				else begin
					writedata_w[71-:8] = "-";
					writedata_w[63-:8] = 8'h30+(8'h09-speed_now_r);
				end
			end
		end
		else begin
			
		end
	end
	default: begin

	end   
	endcase
end


always_ff @(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) begin
		state_r            <= S_IDLE;
		init_stage_r       <= 0; 
		counter_r          <= 0;
		instruct_counter_r <= 0;
		mode_now_r         <= i_mode;
		speed_now_r        <= i_speed;
		control_now_r      <= {i_sto, ~i_pau};
		out_r              <= 0;
		writedata_r        <= 0;
	end
	else begin
		state_r            <= state_w;
		init_stage_r       <= init_stage_w; 
		counter_r          <= counter_w;
		instruct_counter_r <= instruct_counter_w;
		mode_now_r         <= mode_now_w;
		speed_now_r        <= speed_now_w;
		control_now_r      <= control_now_w;
		out_r              <= out_w;
		writedata_r        <= writedata_w;	
	end
end
endmodule
