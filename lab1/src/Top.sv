module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out,
	output       o_changing
);

	// ===== States =====
	parameter S_IDLE = 1'b0;
	parameter S_PROC = 1'b1;

	// ===== Registers & Wires =====
	logic        state, state_nxt;
	logic [3:0]  cycle, cycle_nxt;
	logic [24:0] counter, counter_nxt;
	logic        rnd_set_seed, rnd_gen;

	// ===== Sub Module =====
	PRNG prng_0(
		.i_clk(i_clk),
		.i_rst_n(i_rst_n),
		.i_set_seed(rnd_set_seed),
		.i_seed(counter[20:5]),
		.i_generate(rnd_gen),
		.o_random_num(o_random_out)
	);

	// ===== Combinational Circuits =====
	assign o_changing = (state == S_PROC);

	always_comb begin : FSM
		// default
		state_nxt = state;

		case(state)
			S_IDLE: begin
				if (i_start) begin
					state_nxt = S_PROC;
				end
			end

			S_PROC: begin
				if (i_start || cycle == 4'd15) begin
					state_nxt = S_IDLE;
				end
			end

			default: begin
				state_nxt = S_IDLE;
			end
		endcase
	end

	// scheduler
	always_comb begin
		// default
		cycle_nxt    = cycle;
		counter_nxt  = counter;
		rnd_set_seed = 1'b0;
		rnd_gen      = 1'b0;

		case (state)
			S_IDLE: begin
				if (i_start) begin
					cycle_nxt    = 4'd1;
					counter_nxt  = 25'd0;
					rnd_set_seed = 1'b1;
				end
				else begin
					counter_nxt = counter + 1;
				end
			end

			S_PROC: begin
				if (counter[24:21] == cycle) begin
					cycle_nxt   = cycle + 1;
					counter_nxt = 25'd0;
					rnd_gen     = 1'b1;
				end
				else begin
					counter_nxt = counter + 1;
				end
			end
			default: begin
				cycle_nxt   =  4'd1;
				counter_nxt = 25'd0;
				rnd_gen     =  1'b0;
			end
		endcase
	end

	// ===== Sequential Circuits =====
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		if (!i_rst_n) begin
			state     <= S_IDLE;
			cycle     <= 4'd1;
			counter   <= 25'd0;
		end
		else begin
			state     <= state_nxt;
			cycle     <= cycle_nxt;
			counter   <= counter_nxt;
		end
	end

endmodule

module PRNG(
	input         i_clk,
	input         i_rst_n,
	input         i_set_seed,
	input  [15:0] i_seed,
	input         i_generate,
	output [3:0]  o_random_num
);
	// wire and registers
	logic [14:0] seq1, seq1_nxt;
	logic [10:0] seq2, seq2_nxt;
	logic [9:0]  seq3, seq3_nxt;
	logic [8:0]  seq4, seq4_nxt;

	assign o_random_num = {seq4[0], seq2[0], seq3[0], seq1[0]};
	
	always_comb begin
		seq1_nxt = seq1;
		seq2_nxt = seq2;
		seq3_nxt = seq3;
		seq4_nxt = seq4;

		if (i_set_seed) begin
			// cannot be all 0's
			seq1_nxt = {i_seed[ 9: 5], 1'b1, i_seed[15: 7]};
			seq2_nxt = {i_seed[13:11], 1'b1, i_seed[ 8: 2]};
			seq3_nxt = {i_seed[ 5: 1], 1'b1, i_seed[13:10]};
			seq4_nxt = {i_seed[ 6: 2], 1'b1, i_seed[11: 9]};
		end
		else if (i_generate) begin
			seq1_nxt = {seq1[0],            seq1[0]^seq1[14], seq1[13:1]};    // 15: 13, 14
			seq2_nxt = {seq2[0], seq2[ 10], seq2[0]^seq2[ 9], seq2[ 8:1]};    // 11:  8, 10
			seq3_nxt = {seq3[0], seq3[9:8], seq3[0]^seq3[ 7], seq3[ 6:1]};    // 10:  6,  9
			seq4_nxt = {seq4[0], seq4[8:6], seq4[0]^seq4[ 5], seq4[ 4:1]};    //  9:  4,  8
		end
	end

	always_ff @(posedge i_clk or negedge i_rst_n) begin
		// reset
		if (!i_rst_n) begin
			// cannot be all 0's
			seq1 <= 15'd0;
			seq2 <= 11'd0;
			seq3 <= 10'd0;
			seq4 <=  9'd0;
		end
		else begin
			seq1 <= seq1_nxt;
			seq2 <= seq2_nxt;
			seq3 <= seq3_nxt;
			seq4 <= seq4_nxt;
		end
	end

endmodule
