	component Image_Loader_Wrapper is
		port (
			clk_clk                        : in  std_logic                     := 'X'; -- clk
			reset_reset_n                  : in  std_logic                     := 'X'; -- reset_n
			uart_0_external_connection_rxd : in  std_logic                     := 'X'; -- rxd
			uart_0_external_connection_txd : out std_logic;                            -- txd
			image_loader_wrapper_i_clk     : in  std_logic                     := 'X'; -- i_clk
			image_loader_wrapper_data      : out std_logic_vector(23 downto 0);        -- data
			image_loader_wrapper_valid     : out std_logic                             -- valid
		);
	end component Image_Loader_Wrapper;

	u0 : component Image_Loader_Wrapper
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                        clk.clk
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                      reset.reset_n
			uart_0_external_connection_rxd => CONNECTED_TO_uart_0_external_connection_rxd, -- uart_0_external_connection.rxd
			uart_0_external_connection_txd => CONNECTED_TO_uart_0_external_connection_txd, --                           .txd
			image_loader_wrapper_i_clk     => CONNECTED_TO_image_loader_wrapper_i_clk,     --       image_loader_wrapper.i_clk
			image_loader_wrapper_data      => CONNECTED_TO_image_loader_wrapper_data,      --                           .data
			image_loader_wrapper_valid     => CONNECTED_TO_image_loader_wrapper_valid      --                           .valid
		);

