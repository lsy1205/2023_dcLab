	Image_Loader_Wrapper u0 (
		.clk_clk                        (<connected-to-clk_clk>),                        //                        clk.clk
		.reset_reset_n                  (<connected-to-reset_reset_n>),                  //                      reset.reset_n
		.uart_0_external_connection_rxd (<connected-to-uart_0_external_connection_rxd>), // uart_0_external_connection.rxd
		.uart_0_external_connection_txd (<connected-to-uart_0_external_connection_txd>), //                           .txd
		.image_loader_wrapper_out_data  (<connected-to-image_loader_wrapper_out_data>),  //   image_loader_wrapper_out.data
		.image_loader_wrapper_out_valid (<connected-to-image_loader_wrapper_out_valid>)  //                           .valid
	);

