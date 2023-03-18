module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_msg,    // cipher text y
	input  [255:0] i_key,    // private key d
	input  [255:0] i_n,
	output [255:0] o_ans,    // plain text x
	output         o_finished
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm

localparam S_IDLE = 2'd0;
localparam S_PREP = 2'd1;
localparam S_MONT = 2'd2;
localparam S_CALC = 2'd3;

logic  [1:0] state_r, state_w;
logic[255:0] o_ans_r, o_ans_w;
logic        o_fin_r, o_fin_w;
logic        prep_fin;
logic        mul_fin;
logic        sqr_fin;
logic  [7:0] counter_r, counter_w;

RsaPrep prep_0   (.o_fin(prep_fin));
RsaMont mont_mul (.o_fin(mul_fin));
RsaMont mont_sqr (.o_fin(sqr_fin));

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w = S_PREP;
			end
		end
		S_PREP: begin
			if (prep_fin) begin
				state_w = S_MONT;
			end
		end
		S_MONT: begin
			if (mul_fin && sqr_fin) begin
				state_w = S_CALC;
			end
		end
		S_CALC: begin
			if (counter_r == 8'hff) begin
				state_w = S_IDLE;
			end
			else begin
				state_w = S_MONT;
			end
		end
		default: begin
			state_w = state_r;
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		state_r    <= S_IDLE;
		o_ans_r    <= 0;
		o_fin_r    <= 0;
		prep_fin_r <= 0;
		mul_fin_r  <= 0;
		sqr_fin_r  <= 0;
		counter_r  <= 0;
	end
	else begin
		state_r    <= state_w;
		o_ans_r    <= o_ans_w;
		o_fin_r    <= o_fin_w;
		prep_fin_r <= prep_fin_w;
		mul_fin_r  <= mul_fin_w;
		sqr_fin_r  <= sqr_fin_w;
		counter_r  <= counter_w;
	end
end

endmodule
