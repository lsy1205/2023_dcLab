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
logic  [7:0] counter_r, counter_w;
logic[255:0] key_r, key_w;
logic[255:0] o_ans_r, o_ans_w;
logic        o_fin_r, o_fin_w;
logic        prep_start_r, prep_start_w;
logic        mul_start_r, mul_start_w;
logic        sqr_start_r, sqr_start_w;
logic        prep_fin;
logic        mul_fin;
logic        sqr_fin;
logic[255:0] t_r, t_w;
logic[255:0] t_pre;
logic[255:0] t_sqr;

assign o_ans = o_ans_r;

RsaPrep prep_0 (
	.i_clk(i_clk), 
	.i_rst(i_rst), 
	.i_start(prep_start_r), 
	.i_N(i_n), 
	.i_b(i_msg), 
	.o_fin(prep_fin), 
	.o_m(t_pre)
);
					
RsaMont mont_mul (
	.i_clk(i_clk), 
	.i_rst(i_rst), 
	.i_start(mul_start_r),  
	.i_N(i_n),
    .i_a(o_ans_r), 
	.i_b(t_r),   
	.o_fin(mul_fin),  
	.o_m(o_ans_w)
);

RsaMont mont_sqr (
	.i_clk(i_clk), 
	.i_rst(i_rst), 
	.i_start(sqr_start_r),  
	.i_N(i_n), 
	.i_a(t_r),
	.i_b(t_r), 
	.o_fin(sqr_fin),  
	.o_m(t_sqr));

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
			if (sqr_fin) begin
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

always_comb begin 
	counter_w = counter_r;
	o_fin_w = o_fin_r;
	t_w       = t_r;
	prep_start_w = prep_start_r;
	mul_start_w = mul_start_r;
	sqr_start_w = sqr_start_r;

	case (state_r)
		S_IDLE: begin
			o_fin_w = 0;
			counter_w = 0;
			if(i_start) begin
				key_w = i_key;
				prep_start_w = 1;
			end
		end
		S_PREP: begin
			prep_start_w = 0;
			if (prep_fin) begin
				t_w = t_pre;
			end
		end
		S_MONT: begin
			sqr_start_w = 1;
			if(key_r[0]) begin
				mul_start_w = 1;
			end

			if(mul_fin) begin
				mul_start_w = 0;
			end
			
			if(sqr_fin) begin
				sqr_start_w = 0;
				t_w = t_sqr;
			end
		end
		S_CALC: begin
			counter_w = counter_r + 1;
			key_w = key_r >> 1;
			if (counter_r == 8'hff) begin
				o_fin_w = 1;
			end
		end
		default: begin
			
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		state_r      <= S_IDLE;
		o_ans_r      <= 1;
		o_fin_r      <= 0;
		counter_r    <= 0;
		key_r        <= 0;
		t_r          <= 0;
		prep_start_r <= 0;
		mul_start_r  <= 0;
		sqr_start_r  <= 0;
	end
	else begin
		state_r      <= state_w;
		o_ans_r      <= o_ans_w;
		o_fin_r      <= o_fin_w;
		counter_r    <= counter_w;
		t_r          <= t_w;
		key_r        <= key_w;
		prep_start_r <= prep_start_w;
		mul_start_r  <= mul_start_w;
		sqr_start_r  <= sqr_start_w;
	end
end

endmodule

module RsaPrep (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_N,
	input  [255:0] i_b,
	
	output         o_fin,
	output [255:0] o_m
);

	localparam    IDLE = 1'b0;
	localparam    CALC = 1'b1;

	logic   [7:0] counter_r, counter_w;
	logic [255:0] o_m_r, o_m_w;
	logic         o_fin_r, o_fin_w; 
	logic         state_r, state_w;
	logic [256:0] m_2;

	assign o_fin = o_fin_r;
	assign o_m   = o_m_r;
	assign m_2   = o_m_r << 1;
	

	always_comb begin
		state_w = state_r;

		case (state_r)
		IDLE: begin
			if(i_start) begin
				state_w = CALC;
			end
			else begin
				state_w = IDLE;
			end
		end
		CALC: begin
			if(counter_r == 8'hff) begin
				state_w = IDLE;
			end
			else begin
				state_w = CALC;
			end
		end
		default: begin
			state_w = IDLE;
		end
		endcase	
	end

	always_comb begin
		o_fin_w   = 0;
		counter_w = counter_r;
		o_m_w     = o_m_r;

		case (state_r)
		IDLE:begin
			counter_w = 0;
			if (i_start) begin
				o_m_w = i_b;	
			end
		end
		CALC: begin
			if (counter_r == 8'hff) begin
				o_fin_w = 1;
			end
			else begin
				counter_w = counter_r + 1;
			    o_m_w = (m_2 < i_N) ? m_2 : m_2 - i_N;
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

module RsaMont (
	input          i_clk,
	input  		   i_rst,
	input 		   i_start,
	input  [255:0] i_N,
	input  [255:0] i_a,
	input  [255:0] i_b,
	output         o_fin,
	output [255:0] o_m
);

localparam S_IDLE = 0;
localparam S_CALC = 1;

logic 		  state_r, state_w;
logic 		  fin_r, fin_w;
logic   [8:0] counter_r, counter_w;
logic [255:0] m_r, m_w;
logic [256:0] m_prime;
logic [256:0] m_result_r, m_result_w;
logic [255:0] a_r, a_w;

assign o_fin = fin_r;
assign o_m   = m_result_r;

always_comb begin : FSM
	state_w = state_r;
		
	case (state_r)
		S_IDLE: begin
			if(i_start) begin
				state_w = S_CALC;
			end
		end
		S_CALC: begin
			if(counter_r == 257) begin
				state_w = S_IDLE;
			end
		end
	endcase
end

always_comb begin
	m_w = m_r;
	m_result_w = m_result_r;
	counter_w = counter_r;
	fin_w = fin_r;
	a_w = a_r;

	case (state_r)
		S_IDLE: begin
			m_w = 0;
			counter_w = 0;
			fin_w = 0;
			if(i_start) begin
				a_w = i_a;
			end
		end
		S_CALC: begin
			m_prime = (a_r[0] == 1) ? m_r + i_b : m_r;
			m_w = ((m_prime[0] == 1) ? (m_prime + i_N) : m_prime) >> 1;
			a_w = a_r << 1;
			
			if(counter_r == 257) begin
				m_result_w = (m_r < i_N) ? m_r : m_r - i_N;
				fin_w = 1;
			end
			counter_w = counter_r + 1;
		end
	endcase
end

always_ff @(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		m_r 	   <= 0;
		counter_r  <= 0;
		fin_r 	   <= 0;
		a_r        <= 0;
		m_result_r <= 0;
		state_r    <= S_IDLE;
	end
	else begin
		m_r 	   <= m_w;
		counter_r  <= counter_w;
		fin_r      <= fin_w;
		a_r        <= a_w;
		m_result_r <= m_result_w;
		state_r    <= state_w;
	end
end
	
endmodule
