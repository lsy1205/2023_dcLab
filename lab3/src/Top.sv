module Top (
	input i_rst_n,
	input i_clk,
	input i_sw_0,  // Record=1/Play=0 mode
	input i_sw_1,  // 0/1 order interpolation
	input i_key_0, // Start/Pause
	input i_key_1, // Stop
	input i_key_2, // Speed up
	input i_key_3, // Speed down

	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,

	// I2S
	input  i_AUD_BCLK,
	input  i_AUD_ADCLRCK,
	input  i_AUD_ADCDAT,
	input  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	output [3:0] o_speed,
	output [3:0] o_seg7,

	// LCD (optional display)
	input        i_clk_800k,
	inout  [7:0] io_LCD_DATA,
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW,
	output       o_LCD_ON,
	output       o_LCD_BLON,

	// LED
	output  [8:0] o_ledg,
	output [17:0] o_ledr
);


// design the FSM and states as you like
localparam S_IDLE  = 0;
localparam S_INIT  = 1;
localparam S_RESET = 2;
localparam S_ADC_L = 3;
localparam S_DSP   = 4;
localparam S_DAC_L = 5;
localparam S_DAC_R = 6;
localparam S_PAUSE = 7;

localparam M_PLAY = 0;
localparam M_RECD = 1;

logic        key_0_r, key_0_w;
logic        key_1_r, key_1_w;
logic        key_2_r, key_2_w;
logic        key_3_r, key_3_w;

logic  [2:0] state_r, state_w;
logic        mode_r, mode_w;				// 0: play, 1:record
logic        mode_changed_r, mode_changed_w;
logic  [3:0] speed_r, speed_w;				// 1: 1/8, 2: 1/7, ..., 8: 1, ..., 14: 7, 15: 8
logic        interpol_r, interpol_w;		// 0: 0-order, 1: 1-order
logic        change_en;
logic        speed_up, speed_down;
logic        mem_lim;
logic        pause, stop;

logic  [2:0] next_num;
logic [15:0] play_data, record_data;
logic        mem_start, mem_fin, mem_valid;

logic        i2c_start_r, i2c_start_w;
logic        i2c_fin;

logic        clear;
logic        dsp_start_r, dsp_start_w;
logic        dsp_fin;

logic [15:0] dac_data_r, dac_data_w, new_dacdat;
logic        player_start_r, player_start_w;
logic        player_fin;

logic [15:0] adc_data_r, adc_data_w, new_adcdat;
logic        recorder_start_r, recorder_start_w;
logic        recorder_fin;

logic        lcd_start;

logic  [8:0] ledg_r, ledg_w;
logic [17:0] ledr_r, ledr_w;

assign speed_up   = (i_key_2 | key_2_r) && (speed_r != 15);
assign speed_down = (i_key_3 | key_3_r) && (speed_r !=  1);
assign mem_lim    = (mem_fin && !mem_valid);
assign pause      = (state_r == S_PAUSE);
assign stop       = (state_r == S_RESET);

assign lcd_start  = 1'b1;
assign o_LCD_ON   = 1'b1;
assign o_LCD_BLON = 1'b0;

assign o_seg7  = {lcd_valid, state_r};
assign o_speed = speed_r;

assign o_ledg = ledg_r;
assign o_ledr = ledr_r;
assign ledr_w[ 0] = (mode_r == M_RECD);
assign ledr_w[ 1] = interpol_r;
assign ledr_w[17] = i_rst_n;
always_comb begin
	ledg_w[0] = 0;
	ledg_w[1] = 0;

	case (state_r)
		S_ADC_L, S_DSP, S_DAC_L, S_DAC_R: begin
			ledg_w[0] = 1;
			ledg_w[1] = 1;
		end
		S_PAUSE: begin
			ledg_w[0] = 1;
		end
		default: begin
			ledg_w[0] = 0;
			ledg_w[1] = 0;
		end
	endcase
end


Mem mem0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
	.i_clear(clear),
    .i_mode(mode_r), // 0: play(read), 1: record(write)
    .i_next_num(next_num),
    .i_start(mem_start),
    .o_fin(mem_fin),

    .o_SRAM_ADDR(o_SRAM_ADDR),
	.io_SRAM_DQ(io_SRAM_DQ),
	.o_SRAM_WE_N(o_SRAM_WE_N),
	.o_SRAM_CE_N(o_SRAM_CE_N),
	.o_SRAM_OE_N(o_SRAM_OE_N),
	.o_SRAM_LB_N(o_SRAM_LB_N),
	.o_SRAM_UB_N(o_SRAM_UB_N),

    .o_vaild(mem_valid),
    .o_r_data(play_data),
    .i_w_data(record_data)
);

// === I2CInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2CInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start_r),	// CDC flag
	.o_fin(i2c_fin),		// CDC flag
	.o_scl(o_I2C_SCLK),
	.io_sda(io_I2C_SDAT)
);

// === AudDSP ===
// responsible for DSP operations including fast play, slow play and record
// control address and Start/Pause/Stop
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_clear(clear),
	.i_mode(mode_r),			// 0: play, 1:record
	.i_speed(speed_r),			// 1: 1/8, 2: 1/7, ..., 8: 1, ..., 14: 7, 15: 8
	.i_interpol(interpol_r),	// 0: 0-order, 1: 1-order
	.i_start(dsp_start_r),
	.o_fin(dsp_fin),

	.o_next_num(next_num),		// 0: nxt 1, 1: nxt 2, ..., 7: nxt 8
	.o_mem_start(mem_start),
	.i_mem_fin(mem_fin),

	.i_rdata(play_data),
	.o_dac_data(new_dacdat),

	.i_adc_data(adc_data_r),
	.o_wdata(record_data)
);

// === AudPlayer ===
// receive data from DSP and send to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_start(player_start_r),	// CDC flag
	.o_fin(player_fin),			// CDC flag
	.i_dac_data(dac_data_r),
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and send to DSP
AudRecorder recorder0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_adclrck(i_AUD_ADCLRCK),
	.i_start(recorder_start_r),	// CDC flag
	.o_fin(recorder_fin),		// CDC flag
	.i_aud_adcdat(i_AUD_ADCDAT),
	.o_adc_data(new_adcdat)
);

LCD lcd0 (
    .i_clk(i_clk_800k),
    .i_rst_n(i_rst_n),
	.i_mode(mode_r),
    .i_speed(speed_r),
	.i_pau(pause),
	.i_sto(stop),
	.o_valid(lcd_valid),

	.io_LCD_DATA(io_LCD_DATA),
	.o_LCD_EN(o_LCD_EN),
	.o_LCD_RS(o_LCD_RS),
	.o_LCD_RW(o_LCD_RW)
);

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			state_w = S_INIT;
		end
		S_INIT: begin
			if (i2c_fin) begin
				state_w = S_RESET;
			end
		end
		S_RESET: begin
			if (i_key_0) begin
				state_w = (mode_r) ? S_ADC_L : S_DSP;
			end
		end
		S_ADC_L: begin
			if (recorder_fin) begin
				state_w = S_DSP;
			end
		end
		S_DSP: begin
			if (mem_lim) begin
				state_w = S_RESET;
			end
			if (dsp_fin) begin
				if (mode_r) begin	// record
					state_w = (mode_changed_r | key_1_r) ? S_RESET :
					          (key_0_r) ? S_PAUSE : S_ADC_L;
				end
				else begin			// play
					state_w = S_DAC_L;
				end
			end
		end
		S_DAC_L: begin
			if (player_fin) begin
				state_w = S_DAC_R;
			end
		end
		S_DAC_R: begin
			if (player_fin) begin
				state_w = (mode_changed_r | key_1_r) ? S_RESET :
				          (key_0_r) ? S_PAUSE : S_DSP;
			end
		end
		S_PAUSE: begin
			if ((mode_r != mode_w) | i_key_1) begin
				state_w = S_RESET;
			end
			else if (i_key_0) begin
				state_w = (mode_r) ? S_ADC_L : S_DSP;
			end
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin : CTRL_SETTING
	mode_w  = mode_r;
	speed_w = speed_r;
	interpol_w = interpol_r;
	key_0_w = key_0_r | i_key_0;
	key_1_w = key_1_r | i_key_1;
	key_2_w = key_2_r | i_key_2;
	key_3_w = key_3_r | i_key_3;
	mode_changed_w = mode_changed_r | (mode_r != mode_w);

	case (state_r)
		S_IDLE, S_INIT: begin
			key_0_w = 0; key_1_w = 0;
			key_2_w = 0; key_3_w = 0;
			mode_changed_w = 0;
		end
		S_RESET: begin
			mode_w = i_sw_0;
			speed_w = (speed_up)   ? speed_r + 1 :
                      (speed_down) ? speed_r - 1 : speed_r;
			interpol_w = i_sw_1;

			key_0_w = 0; key_1_w = 0;
			key_2_w = 0; key_3_w = 0;
			mode_changed_w = 0;
		end
		S_ADC_L: begin
			speed_w = (speed_up)   ? speed_r + 1 :
                      (speed_down) ? speed_r - 1 : speed_r;
			interpol_w = i_sw_1;

			key_2_w = 0; key_3_w = 0;
		end
		S_DSP: begin
			if (mode_r) begin	// record
				mode_w  = i_sw_0;
				speed_w = (speed_up)   ? speed_r + 1 :
                          (speed_down) ? speed_r - 1 : speed_r;
				interpol_w = i_sw_1;

				key_2_w = 0; key_3_w = 0;
				if (dsp_fin) begin
					key_0_w = 0; key_1_w = 0;
					mode_changed_w = 0;
				end
			end
		end
		S_DAC_L: begin
			
		end
		S_DAC_R: begin
			mode_w = i_sw_0;
			speed_w = (speed_up)   ? speed_r + 1 :
                      (speed_down) ? speed_r - 1 : speed_r;
			interpol_w = i_sw_1;

			key_2_w = 0; key_3_w = 0;
			if (player_fin) begin
				key_0_w = 0; key_1_w = 0;
				mode_changed_w = 0;
			end
		end
		S_PAUSE: begin
			mode_w = i_sw_0;
			speed_w = (speed_up)   ? speed_r + 1 :
                      (speed_down) ? speed_r - 1 : speed_r;
			interpol_w = i_sw_1;

			key_0_w = 0; key_1_w = 0;
			key_2_w = 0; key_3_w = 0;
			mode_changed_w = 0;
		end
		default: begin
			mode_w  = mode_r;
			speed_w = speed_r;
			interpol_w = interpol_r;
			key_0_w = key_0_r | i_key_0;
			key_1_w = key_1_r | i_key_1;
			key_2_w = key_2_r | i_key_2;
			key_3_w = key_3_r | i_key_3;
			mode_changed_w = mode_changed_r | (mode_r != mode_w);
		end
	endcase
end

always_comb begin : CTRL_START
	clear = 0;
	adc_data_w  = adc_data_r;
	dac_data_w  = dac_data_r;
	i2c_start_w = i2c_start_r;
	dsp_start_w      = 0;
	player_start_w   = 0;
	recorder_start_w = 0;

	case (state_r)
		S_IDLE: begin
			i2c_start_w = 1;
		end
		S_INIT: begin

		end
		S_RESET: begin
			clear = 1;
			if (i_key_0) begin
				if (mode_r) begin	// record
					recorder_start_w = 1;
				end
				else begin			// play
					dsp_start_w = 1;
				end
			end
		end
		S_ADC_L: begin
			if (recorder_fin) begin
				adc_data_w = new_adcdat;
				dsp_start_w = 1;
			end
		end
		S_DSP: begin
			if (dsp_fin) begin
				if (mode_r) begin	// record
					recorder_start_w = 1;
				end
				else begin			// play
					dac_data_w = new_dacdat;
					player_start_w = 1;
				end
			end
		end
		S_DAC_L: begin
			if (player_fin) begin
				player_start_w = 1;
			end
		end
		S_DAC_R: begin
			if (player_fin) begin
				dsp_start_w = 1;
			end
		end
		S_PAUSE: begin
			if (i_key_0) begin
				if (mode_r) begin	// record
					recorder_start_w = 1;
				end
				else begin			// play
					dsp_start_w = 1;
				end
			end
		end
		default: begin
			clear = 0;
			adc_data_w  = adc_data_r;
			dac_data_w  = dac_data_r;
			i2c_start_w = i2c_start_r;
			dsp_start_w      = 0;
			player_start_w   = 0;
			recorder_start_w = 0;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		key_0_r          <=   1'b0;
		key_1_r          <=   1'b0;
		key_2_r          <=   1'b0;
		key_3_r          <=   1'b0;
		state_r          <= S_IDLE;
		mode_r           <= M_RECD;
		mode_changed_r   <=   1'b0;
		speed_r          <=   4'd8;
		interpol_r       <=   1'b0;
		dac_data_r       <=  16'b0;
		adc_data_r       <=  16'b0;
		i2c_start_r      <=   1'b0;
		dsp_start_r      <=   1'b0;
		player_start_r   <=   1'b0;
		recorder_start_r <=   1'b0;
		ledg_r           <=   9'b0;
		ledr_r           <=  18'b0;
	end
	else begin
		key_0_r          <= key_0_w;
		key_1_r          <= key_1_w;
		key_2_r          <= key_2_w;
		key_3_r          <= key_3_w;
		state_r          <= state_w;
		mode_r           <= mode_w;
		mode_changed_r   <= mode_changed_w;
		speed_r          <= speed_w;
		interpol_r       <= interpol_w;
		dac_data_r       <= dac_data_w;
		adc_data_r       <= adc_data_w;
		i2c_start_r      <= i2c_start_w;
		dsp_start_r      <= dsp_start_w;
		player_start_r   <= player_start_w;
		recorder_start_r <= recorder_start_w;
		ledg_r           <= ledg_w;
		ledr_r           <= ledr_w;
	end
end

endmodule
