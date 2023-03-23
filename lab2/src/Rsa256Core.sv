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
		counter_r  <= 0;
	end
	else begin
		state_r    <= state_w;
		o_ans_r    <= o_ans_w;
		o_fin_r    <= o_fin_w;
		counter_r  <= counter_w;
	end
end

endmodule

module RsaPrep (
	output o_fin
);
	
endmodule

module RsaMont (
	input          i_clk,
	input 		   i_start,
	input  [255:0] i_N,
	input  [255:0] i_a,
	input  [255:0] i_b,
	output         o_fin,
	output [255:0] o_m
);

// localparam S_IDLE = 0;
// localparam S_CALC = 1;

logic [255:0] m_w, m_r;
logic   [7:0] counter_w, counter_r;
logic 		  fin_w, fin_r;
// logic 		  state_w, state_r;

assign o_fin = fin_r;
assign o_m   = m_r;

// always_comb begin
// 	state_w = state_r;
		
// 	case (state_r)
// 		S_IDLE: begin
// 			if(i_start) begin
// 				state_w = S_CALC;
// 			end
// 		end
// 		S_CALC: begin
// 			if(counter_r == 256) begin
// 				state_w = S_IDLE;
// 			end
// 		end
// 	endcase
// end

always_comb begin
	m_w = m_r;
	if(i_a[counter_r] == 1) begin
		m_w = m_r + i_b;
	end
	
	if(m_w[0] == 1) begin
		m_w = m_w - i_N;
	end

	m_w = m_w >> 1;

	if(counter_r == 255) begin
		if(m_w >= i_N) begin
			m_w = m_w - i_N;
		end
		fin_w = 1;
	end
	else begin
		fin_w = 0;
	end

	counter_w = counter_r + 1;
end

always_ff @(posedge i_clk or posedge i_start) begin
	if(i_start) begin
		m_r 	  <= 0;
		counter_r <= 0;
		fin_r 	  <= 0;
	end
	else begin
		m_r 	  <= m_w;
		counter_r <= counter_w;
		fin_r     <= fin_w;
	end
end
	
endmodule
