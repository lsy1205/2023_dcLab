	component test is
		port (
			clk_clk                         : in  std_logic                     := 'X'; -- clk
			reset_reset_n                   : in  std_logic                     := 'X'; -- reset_n
			uart_0_external_connection_rxd  : in  std_logic                     := 'X'; -- rxd
			uart_0_external_connection_txd  : out std_logic;                            -- txd
			test_loader_0_conduit_end_name  : in  std_logic                     := 'X'; -- name
			test_loader_0_conduit_end_data  : out std_logic_vector(23 downto 0);        -- data
			test_loader_0_conduit_end_valid : out std_logic                             -- valid
		);
	end component test;

	u0 : component test
		port map (
			clk_clk                         => CONNECTED_TO_clk_clk,                         --                        clk.clk
			reset_reset_n                   => CONNECTED_TO_reset_reset_n,                   --                      reset.reset_n
			uart_0_external_connection_rxd  => CONNECTED_TO_uart_0_external_connection_rxd,  -- uart_0_external_connection.rxd
			uart_0_external_connection_txd  => CONNECTED_TO_uart_0_external_connection_txd,  --                           .txd
			test_loader_0_conduit_end_name  => CONNECTED_TO_test_loader_0_conduit_end_name,  --  test_loader_0_conduit_end.name
			test_loader_0_conduit_end_data  => CONNECTED_TO_test_loader_0_conduit_end_data,  --                           .data
			test_loader_0_conduit_end_valid => CONNECTED_TO_test_loader_0_conduit_end_valid  --                           .valid
		);

