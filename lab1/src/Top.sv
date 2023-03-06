module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first

endmodule

module PRNG (
	input  [15:0] seed,
	input         gen,
	output [3:0]  random_num
);
	
endmodule
