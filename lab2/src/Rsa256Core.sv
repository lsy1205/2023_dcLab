module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d, // private key
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm

localparam S_IDLE = 2'd0;
localparam S_PREP = 2'd1;
localparam S_MONT = 2'd2;
localparam S_CALC = 2'd3;



endmodule
