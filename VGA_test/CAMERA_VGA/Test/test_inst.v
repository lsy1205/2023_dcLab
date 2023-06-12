	test u0 (
		.clk_clk                         (<connected-to-clk_clk>),                         //                        clk.clk
		.reset_reset_n                   (<connected-to-reset_reset_n>),                   //                      reset.reset_n
		.uart_0_external_connection_rxd  (<connected-to-uart_0_external_connection_rxd>),  // uart_0_external_connection.rxd
		.uart_0_external_connection_txd  (<connected-to-uart_0_external_connection_txd>),  //                           .txd
		.test_loader_0_conduit_end_name  (<connected-to-test_loader_0_conduit_end_name>),  //  test_loader_0_conduit_end.name
		.test_loader_0_conduit_end_data  (<connected-to-test_loader_0_conduit_end_data>),  //                           .data
		.test_loader_0_conduit_end_valid (<connected-to-test_loader_0_conduit_end_valid>)  //                           .valid
	);

