module LCD (
    input        i_clk,
    input        i_rst_n,
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

// STATE
localparam S_INIT  = 0;  // init LCD
localparam S_FETCH = 1;
localparam S_BUSY  = 2;  // check busy flag
localparam S_WRITE = 3;  // write display data
localparam S_WAIT  = 4;	 // wait new display

// control
localparam CTRL_START = 0;
localparam CTRL_PAUSE = 1;
localparam CTRL_STOP  = 2;

// INITIALIZE
localparam INSTRUCT_0 = 10'b000011_1000;
localparam INSTRUCT_1 = 10'b000000_1100;
localparam INSTRUCT_2 = 10'b000000_0001;
localparam INSTRUCT_3 = 10'b000000_0110;


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

// string           "0123456789ABCDEF"
localparam LINE_1 = "  RECORD PLAY   ";
localparam LINE_2 = "START PAUSE STOP";

// == regs and wires  == //
logic   [2:0] state_r, state_w;
logic  [20:0] counter_r, counter_w;

logic         mode_now_r, mode_now_w;   // 0: play 1: record
logic   [3:0] speed_now_r, speed_now_w; //  1: 1/8, 2: 1/7, ..., 8: 1, ..., 14: 7, 15: 8
logic   [1:0] control_now_r, control_now_w; // 00:start, 01:pause, 1x: stop
logic         new_data;

logic   [9:0] out_r, out_w;
logic [255:0] write_data_r, write_data_w;
logic  [31:0] data_mask_r, data_mask_w;

assign o_valid = (counter_r[1:0] == 2'b11);
assign {o_LCD_RS, o_LCD_RW, io_LCD_DATA} = out_r;
assign o_LCD_EN = 1'b1;

assign new_data = (mode_now_r != mode_now_w) || (speed_now_r != speed_now_w);

always_comb begin: FSM 
	state_w = state_r;

	case (state_r)
		S_INIT: begin
			state_w = (counter_r == 20'hfffff) ? S_FETCH : S_INIT;
		end
		S_FETCH: begin
			state_w = S_BUSY;
		end
		S_BUSY: begin
			state_w = (io_LCD_DATA[7]) ? S_BUSY : S_WRITE;
		end
		S_WRITE: begin
			state_w = (counter_r[6]) ? S_WAIT : S_BUSY;
		end
		S_WAIT: begin
			state_w = (new_data) ? S_FETCH : S_WAIT;
		end
		default: begin
			state_w = S_INIT;
		end
	endcase
end

always_comb begin
	counter_w     = counter_r;
	mode_now_w    = i_mode;
	speed_now_w   = i_speed;
	control_now_w = {i_sto, i_pau};
	write_data_w  = write_data_r;
	data_mask_w   = 0;
	out_w         = out_r;

	case (state_r)
		S_INIT: begin
			counter_w = counter_r + 1;

			if (counter_r < 20'hffffc) begin		// 1111_1111_1111_1111_1100
				out_w = INSTRUCT_0;
			end
			else begin
				case (counter_r[1:0])
					2'b00: begin
						out_w = INSTRUCT_1;
					end
					2'b01: begin
						out_w = INSTRUCT_2;
					end
					2'b10: begin
						out_w = INSTRUCT_3;
					end
					default: begin
						out_w = {BUSY, 8'bz};
					end
				endcase
			end
		end
		S_FETCH: begin
			counter_w = 0;
			write_data_w = {LINE_1, LINE_2};

			data_mask_w[31:16] = (mode_now_r) ? 16'h3f00 : 16'h0078;

			case (control_now_r)
				CTRL_START: data_mask_w[15:0] = 16'hf800;
				CTRL_PAUSE: data_mask_w[15:0] = 16'h03e0;
				CTRL_STOP : data_mask_w[15:0] = 16'h000f;
				default   : data_mask_w[15:0] = 16'h0000;
			endcase

			// begin  // play
			// 	write_data_w[255-:24] = "   ";
			// 	if(speed_now_r[3]) begin
			// 		write_data_w[71-:8] = "+";
			// 		write_data_w[63-:8] = speed_now_r + 8'h29;  // 8'h30+(speed_now_r-8'h07);
			// 	end
			// 	else begin
			// 		write_data_w[71-:8] = "-";
			// 		write_data_w[63-:8] = 8'h39 - speed_now_r;  // 8'h30+(8'h09-speed_now_r);
			// 	end
			// end
		end
		S_BUSY: begin
			out_w = {BUSY, 8'bz};
		end
		S_WRITE: begin
			counter_w = counter_r + 1;
			if(counter_r[0]) begin     // 進 write
				out_w = {WRITE_DATA, (data_mask_r[31]) ? write_data_r[255-:8] : 8'b0};
				write_data_w = write_data_r << 8;
				data_mask_w  = data_mask_r  << 1;
			end
			else begin  // 進 shift
				out_w = {DDRAM, (counter_r[5]) ? 3'h4 : 3'h0, counter_r[4:1]};
			end
		end
		S_WAIT: begin
			out_w = {BUSY, 8'bz};
		end
		default: begin
			out_w = {BUSY, 8'bz};
		end
	endcase
end


always_ff @(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) begin
		state_r       <= S_INIT;
		counter_r     <= 0;
		mode_now_r    <= 0;
		speed_now_r   <= 0;
		control_now_r <= 0;
		write_data_r  <= 0;
		data_mask_r   <= 0;
		out_r         <= 0;
	end
	else begin
		state_r       <= state_w;
		counter_r     <= counter_w;
		mode_now_r    <= mode_now_w;
		speed_now_r   <= speed_now_w;
		control_now_r <= control_now_w;
		write_data_r  <= write_data_w;
		data_mask_r   <= data_mask_w;
		out_r         <= out_w;
	end
end
endmodule
