
module AltPLL (
	i_clk_clk,
	i_reset_reset,
	altpll_50m_clk,
	altpll_12m_clk,
	altpll_100k_clk,
	altpll_800k_clk);	

	input		i_clk_clk;
	input		i_reset_reset;
	output		altpll_50m_clk;
	output		altpll_12m_clk;
	output		altpll_100k_clk;
	output		altpll_800k_clk;
endmodule
