
module test (
	clk_clk,
	reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	test_loader_0_conduit_end_name,
	test_loader_0_conduit_end_data,
	test_loader_0_conduit_end_valid);	

	input		clk_clk;
	input		reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	input		test_loader_0_conduit_end_name;
	output	[23:0]	test_loader_0_conduit_end_data;
	output		test_loader_0_conduit_end_valid;
endmodule
