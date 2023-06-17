
module Image_Loader_Wrapper (
	clk_clk,
	reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	image_loader_wrapper_i_clk,
	image_loader_wrapper_data,
	image_loader_wrapper_valid);	

	input		clk_clk;
	input		reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	input		image_loader_wrapper_i_clk;
	output	[23:0]	image_loader_wrapper_data;
	output		image_loader_wrapper_valid;
endmodule
