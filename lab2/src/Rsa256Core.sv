module Rsa256Core #(
    parameter  KEY_W     = 256
) (
	input              i_clk,
	input              i_rst,
	input              i_start,
	input  [KEY_W-1:0] i_msg,    // cipher text y
	input  [KEY_W-1:0] i_key,    // private key d
	input  [KEY_W-1:0] i_n,
	output [KEY_W-1:0] o_ans,    // plain text x
	output             o_finished
);

localparam COUNTER_W = $clog2(KEY_W);

// operations for RSA256 decryption
// namely, the Montgomery algorithm

localparam S_IDLE = 0;
localparam S_PREP = 1;
localparam S_MONT = 2;
localparam S_CALC = 3;

logic           [1:0] state_r, state_w;
logic [COUNTER_W-1:0] counter_r, counter_w;
logic                 o_fin_r, o_fin_w;
logic     [KEY_W-1:0] msg_r, msg_w;
logic     [KEY_W-1:0] key_r, key_w;
logic     [KEY_W-1:0] n_r, n_w;
logic     [KEY_W-1:0] ans_r, ans_w;
logic     [KEY_W-1:0] t_r, t_w;
logic                 prep_start_r, prep_start_w;
logic                 mul_start_r, mul_start_w;
logic                 sqr_start_r, sqr_start_w;
logic                 prep_fin;
logic                 mul_fin;
logic                 sqr_fin;
logic     [KEY_W-1:0] t_pre;
logic     [KEY_W-1:0] t_sqr;
logic     [KEY_W-1:0] mul_ans;

assign o_ans = ans_r;
assign o_finished = o_fin_r;

RsaPrep #(.KEY_W(KEY_W)) prep_0 (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(prep_start_r),
	.i_N(i_n),
	.i_b(msg_r),
	.o_m(t_pre),
	.o_fin(prep_fin)
);
					
RsaMont #(.KEY_W(KEY_W)) mont_mul (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(mul_start_r), 
	.i_N(n_r),
	.i_a(t_r),
    .i_b(ans_r),
	.o_m(mul_ans),
	.o_fin(mul_fin)
);

RsaMont #(.KEY_W(KEY_W)) mont_sqr (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(sqr_start_r),
	.i_N(n_r),
	.i_a(t_r),
	.i_b(t_r),
	.o_m(t_sqr),
	.o_fin(sqr_fin)
);

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
			if (sqr_fin && mul_fin) begin
				state_w = S_CALC;
			end
		end
		S_CALC: begin
			if (counter_r == KEY_W-1) begin
				state_w = S_IDLE;
			end
			else begin
				state_w = S_MONT;
			end
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin 
	counter_w    = counter_r;
	msg_w        = msg_r;
	key_w        = key_r;
	n_w          = n_r;
	o_fin_w      = 0;
	ans_w        = ans_r;
	t_w          = t_r;
	prep_start_w = 0;
	mul_start_w  = 0;
	sqr_start_w  = 0;

	case (state_r)
		S_IDLE: begin
			counter_w = 0;
			if(i_start) begin
				msg_w = i_msg;
				key_w = i_key;
				n_w   = i_n;
				ans_w = 1;
				prep_start_w = 1;
			end
		end
		S_PREP: begin
			if (prep_fin) begin
				t_w = t_pre;
				mul_start_w = 1;
				sqr_start_w = 1;	
			end
		end
		S_MONT: begin
			if(sqr_fin) begin
				t_w   = t_sqr;
				ans_w = key_r[0] ? mul_ans : ans_r;
			end
		end
		S_CALC: begin
			counter_w = counter_r + 1;
			key_w     = key_r >> 1;
			if (counter_r == KEY_W-1) begin
				o_fin_w = 1;
			end
			else begin
				mul_start_w = 1;
				sqr_start_w = 1;
			end
		end
		default: begin
			
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		state_r      <= S_IDLE;
		counter_r    <= 0;
		o_fin_r      <= 0;
		msg_r        <= 0;
		key_r        <= 0;
		n_r          <= 0;
		ans_r        <= 1;
		t_r          <= 0;
		prep_start_r <= 0;
		mul_start_r  <= 0;
		sqr_start_r  <= 0;
	end
	else begin
		state_r      <= state_w;
		counter_r    <= counter_w;
		o_fin_r      <= o_fin_w;
		msg_r        <= msg_w;
		key_r        <= key_w;
		n_r          <= n_w;
		ans_r        <= ans_w;
		t_r          <= t_w;
		prep_start_r <= prep_start_w;
		mul_start_r  <= mul_start_w;
		sqr_start_r  <= sqr_start_w;
	end
end

endmodule

module RsaPrep #(
    parameter  KEY_W     = 256
) (
	input              i_clk,
	input              i_rst,
	input              i_start,
	input  [KEY_W-1:0] i_N,
	input  [KEY_W-1:0] i_b,
	
	output [KEY_W-1:0] o_m,
	output             o_fin
);

localparam COUNTER_W = $clog2(KEY_W);

localparam S_IDLE = 0;
localparam S_CALC = 1;

logic                 state_r, state_w;
logic [COUNTER_W-1:0] counter_r, counter_w;
logic     [KEY_W-1:0] o_m_r, o_m_w;
logic                 o_fin_r, o_fin_w; 
logic [(KEY_W+1)-1:0] m_2;

assign o_m   = o_m_r;
assign o_fin = o_fin_r;
assign m_2   = o_m_r << 1;

always_comb begin
	state_w = state_r;

	case (state_r)
	S_IDLE: begin
		if(i_start) begin
			state_w = S_CALC;
		end
	end
	S_CALC: begin
		if(counter_r == KEY_W-1) begin
			state_w = S_IDLE;
		end
	end
	default: begin
		state_w = S_IDLE;
	end
	endcase	
end

always_comb begin
	counter_w = counter_r;
	o_m_w     = o_m_r;
	o_fin_w   = 0;

	case (state_r)
	S_IDLE:begin
		counter_w = 0;
		o_m_w     = (i_start) ? i_b : 0;
	end
	S_CALC: begin
		counter_w = counter_r + 1;
		o_m_w     = (m_2 < i_N) ? m_2 : m_2 - i_N;
		if (counter_r == KEY_W-1) begin
			o_fin_w = 1;
		end
	end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		state_r   <= 0;
		counter_r <= 0;
		o_m_r     <= 0;
		o_fin_r   <= 0;
	end
	else begin
		state_r   <= state_w;
		counter_r <= counter_w;
		o_m_r     <= o_m_w;
		o_fin_r   <= o_fin_w;
	end
end

endmodule

module RsaMont #(
    parameter  KEY_W     = 256
) (
	input              i_clk,
	input              i_rst,
	input              i_start,
	input  [KEY_W-1:0] i_N,
	input  [KEY_W-1:0] i_a,
	input  [KEY_W-1:0] i_b,
	output [KEY_W-1:0] o_m,
	output             o_fin
);

localparam COUNTER_W = $clog2(KEY_W);


localparam S_IDLE = 0;
localparam S_CALC = 1;

logic                     state_r, state_w;
logic [(COUNTER_W+1)-1:0] counter_r, counter_w;
logic     [(KEY_W+1)-1:0] m_r, m_w;
logic                     fin_r, fin_w;
logic         [KEY_W-1:0] a_r, a_w;
logic     [(KEY_W+2)-1:0] m_add;

assign o_m   = m_r;
assign o_fin = fin_r;
assign m_add = (a_r[0] == 1) ? m_r + i_b : m_r;

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w = S_CALC;
			end
		end
		S_CALC: begin
			if (counter_r == KEY_W) begin
				state_w = S_IDLE;
			end
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin
	counter_w = counter_r;
	m_w = m_r;
	fin_w = 0;
	a_w = a_r;

	case (state_r)
		S_IDLE: begin
			counter_w = 0;
			a_w = (i_start) ? i_a : 0;
			m_w = 0;
		end
		S_CALC: begin
			counter_w = counter_r + 1;
			a_w       = a_r >> 1;
			if(counter_r == KEY_W) begin
				m_w = (m_r < i_N) ? m_r : m_r - i_N;
				fin_w = 1;
			end
			else begin
				m_w = ((m_add[0] == 1) ? (m_add + i_N) : m_add) >> 1;
			end
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		state_r   <= S_IDLE;
		counter_r <= 0;
		a_r       <= 0;
		m_r       <= 0;
		fin_r     <= 0;
	end
	else begin
		state_r   <= state_w;
		counter_r <= counter_w;
		a_r       <= a_w;
		m_r       <= m_w;
		fin_r     <= fin_w;
	end
end

endmodule
