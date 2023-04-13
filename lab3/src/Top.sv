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
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
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
localparam S_IDLE       = 0;
localparam S_INIT       = 1;
localparam S_RECD       = 2;
localparam S_PLAY       = 4;

logic        state_r, state_w;
logic [19:0] data_addr;
logic [15:0] read_data, write_data;
logic [15:0] dac_data, adc_data;

assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = data_addr;
assign io_SRAM_DQ  = (state_r == S_RECD) ? write_data : 16'dz; // sram_dq as output
assign read_data   = (state_r == S_PLAY) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b1;
assign o_SRAM_OE_N = 1'b1;
assign o_SRAM_LB_N = 1'b1;
assign o_SRAM_UB_N = 1'b1;

// === I2CInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2CInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100K),
	.i_start(),
	.o_finished(),
	.o_scl(o_I2C_SCLK),
	.o_sda(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play, slow play and record
// control address and Start/Pause/Stop
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_stage(),		// 0: reset, 1: stay, 2: increment
	.i_speed(),		// 0: 1/8, 1: 1/7, ..., 7: 1, ..., 13: 7, 14: 8

	.i_lrck(lrck),
	.o_data_addr(o_data_addr),

	.i_rdata(read_data),
	.o_dac_data(dac_data),

	.i_adc_data(adc_data),
	.o_wdata(write_data)
);

// === AudPlayer ===
// receive data from DSP and send to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(),
	.i_dac_data(dac_data),
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and send to DSP
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_adclrck(i_AUD_ADCLRCK),
	.i_en(),
	.i_aud_adcdat(i_AUD_ADCDAT),
	.o_adc_data(adc_data)
);

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			state_w = S_INIT;
		end 
		S_INIT: begin
			if(!i_sw_0) begin
				state_w = S_PLAY;
			end
			else begin
				state_w = S_RECD;
			end
		end
		S_PLAY: begin
			if(!i_sw_0) begin
				state_w = S_PLAY;
			end
			else begin
				state_w = S_RECD;
			end
		end
		S_RECD: begin
			if(!i_sw_0) begin
				state_w = S_PLAY;
			end
			else begin
				state_w = S_RECD;
			end
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase

end

always_comb begin
	// design your control here
end

always_ff @(posedge i_AUD_BCLK or posedge i_rst_n) begin
	if (!i_rst_n) begin
		
	end
	else begin
		
	end
end

endmodule
