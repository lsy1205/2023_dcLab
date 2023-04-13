module Top (
	input i_rst_n,
	input i_clk,
	input i_sw_0,  // Record=1/Play=0 mode
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
	inout  i_AUD_BCLK,
	inout  i_AUD_ADCLRCK,
	input  i_AUD_ADCDAT,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	input        i_clk_800k,
	inout  [7:0] o_LCD_DATA,
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
localparam S_INIT  = 0;
localparam S_RESET = 1;
localparam S_INCRE = 2;
localparam S_PAUSE = 3;

localparam M_PLAY = 0;
localparam M_RECD = 1;


logic  [1:0] state_r, state_w;
logic  [1:0] counter_r, counter_w;
logic        mode_r, mode_w;
logic  [3:0] speed_r, speed_w;
logic        mem_lim;

logic [19:0] data_addr;
logic [15:0] play_data, record_data;

logic        i2c_start_r, i2c_start_w;
logic        i2c_fin;
// logic        i2c_scl, i2c_sda, i2c_oen;

logic [15:0] dac_data;
logic        player_start_r, player_start_w;
logic        player_fin;

logic [15:0] adc_data;
logic        recorder_start_r, recorder_start_w;
logic        recorder_fin;


assign mode_w   = i_sw_0;		// 0: play, 1:record
assign mem_lim = (data_addr == 20'hfffff);

assign o_SRAM_ADDR = data_addr;
assign io_SRAM_DQ  = (mode_r == M_RECD) ? record_data : 16'dz; // sram_dq as output
assign play_data   = (mode_r == M_PLAY) ?  io_SRAM_DQ : 16'd0; // sram_dq as input
assign o_SRAM_WE_N = (mode_r == M_RECD) ?        1'b0 :  1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// assign o_I2C_SCLK  = i2c_scl;
// assign io_I2C_SDAT = (i2c_oen) ? i2c_sda : 1'bz;

assign o_LCD_DATA = 'b0;
assign o_LCD_EN   = 'b1;
assign o_LCD_RS   = 'bz;
assign o_LCD_RW   = 'bz;
assign o_LCD_ON   = 'b0;  // 'b1;
assign o_LCD_BLON = 'b0;

assign o_ledg =  9'b0;
assign o_ledr = 18'b0;

// === I2CInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2CInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100K),
	.i_start(i2c_start_r),
	.o_fin(i2c_fin),
	.o_scl(o_I2C_SCLK),
	.io_sda(io_I2C_SDAT)
	// .o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play, slow play and record
// control address and Start/Pause/Stop
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_ctrl(state_r),		// 1: reset, 2: increment, 3: pause
	.i_speed(speed_r),		// 0: 1/8, 1: 1/7, ..., 7: 1, ..., 13: 7, 14: 8
	.o_data_addr(data_addr),

	.i_dac_lrck(i_AUD_DACLRCK),
	.i_rdata(play_data),
	.o_dac_data(dac_data),

	.i_adc_lrck(i_AUD_ADCLRCK),
	.i_adc_data(adc_data),
	.o_wdata(record_data)
);

// === AudPlayer ===
// receive data from DSP and send to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_start(player_start_r),
	.o_fin(player_fin),
	.i_dac_data(dac_data),
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and send to DSP
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_bclk(i_AUD_BCLK),
	.i_adclrck(i_AUD_ADCLRCK),
	.i_start(recorder_start_r),
	.o_fin(recoder_fin),
	.i_aud_adcdat(i_AUD_ADCDAT),
	.o_adc_data(adc_data)
);

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_INIT: begin
			if (i2c_fin) begin
				state_w = S_RESET;
			end
		end 
		S_RESET: begin
			if (i_key_0) begin
				state_w = S_INCRE;
			end
		end
		S_INCRE: begin
			if (i_key_1 || mem_lim) begin
				state_w = S_RESET;
			end
			else if (i_key_0) begin
				state_w = S_PAUSE;
			end
		end
		S_PAUSE: begin
			if (i_key_1) begin
				state_w = S_RESET;
			end
			else if (i_key_0) begin
				state_w = S_INCRE;
			end
		end
		default: begin
			state_w = S_INIT;
		end
	endcase

end

always_comb begin
	// design your control here
	counter_w = counter_r;
	i2c_start_w      = 0;
	player_start_w   = 0;
	recorder_start_w = 0;

	case (state_r)
		S_INIT: begin
			counter_w = counter_r + 1;
			if (counter_r == 0) begin
				i2c_start_w = 1;
			end
		end 
		S_RESET: begin
			if (1'b0) begin
				
			end
		end
		S_INCRE: begin
			if (1'b0) begin
				
			end
			else if (1'b0) begin
				
			end
		end
		S_PAUSE: begin
			if (1'b0) begin
				
			end
			else if (1'b0) begin
				
			end
		end
		default: begin
			
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r          <= S_INIT;
		counter_r        <= 2'b0;
		mode_r           <= M_RECD;
		speed_r          <= 4'd7;
		i2c_start_r      <= 1'b0;
		player_start_r   <= 1'b0;
		recorder_start_r <= 1'b0;
	end
	else begin
		state_r          <= state_w;
		counter_r        <= counter_w;
		mode_r           <= mode_w;
		speed_r          <= speed_w;
		i2c_start_r      <= i2c_start_w;
		player_start_r   <= player_start_w;
		recorder_start_r <= recorder_start_w;
	end
end

endmodule
