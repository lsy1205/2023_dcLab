module AudDSP (
    input         i_rst_n,
	input         i_clk,
	input         i_ctrl,		// 0: reset, 1: stay, 2: increment
	input         i_speed,		// 0: 1/8, 1: 1/7, ..., 7: 1, ..., 13: 7, 14: 8
	output [19:0] o_data_addr,

	input         i_dac_lrck,
	input  [15:0] i_rdata,
	output [15:0] o_dac_data,

	input         i_adc_lrck,
	input  [15:0] i_adc_data,
	output [15:0] o_wdata
);
    
endmodule
