	component AltPLL is
		port (
			i_clk_clk       : in  std_logic := 'X'; -- clk
			i_reset_reset   : in  std_logic := 'X'; -- reset
			altpll_50m_clk  : out std_logic;        -- clk
			altpll_12m_clk  : out std_logic;        -- clk
			altpll_100k_clk : out std_logic;        -- clk
			altpll_800k_clk : out std_logic         -- clk
		);
	end component AltPLL;

	u0 : component AltPLL
		port map (
			i_clk_clk       => CONNECTED_TO_i_clk_clk,       --       i_clk.clk
			i_reset_reset   => CONNECTED_TO_i_reset_reset,   --     i_reset.reset
			altpll_50m_clk  => CONNECTED_TO_altpll_50m_clk,  --  altpll_50m.clk
			altpll_12m_clk  => CONNECTED_TO_altpll_12m_clk,  --  altpll_12m.clk
			altpll_100k_clk => CONNECTED_TO_altpll_100k_clk, -- altpll_100k.clk
			altpll_800k_clk => CONNECTED_TO_altpll_800k_clk  -- altpll_800k.clk
		);

