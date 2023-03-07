module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

	// ===== States =====
	parameter S_IDLE = 1'b0;
	parameter S_PROC = 1'b1;

	// ===== Output Buffers =====
	logic [3:0] o_random_out, o_random_out_nxt;

	// ===== Registers & Wires =====
	logic        state, state_nxt;
	logic [3:0]  cycle, cycle_nxt;
	logic        rnd_gen, rnd_gen_nxt;
	logic [24:0] counter, counter_nxt;
	logic [15:0] rnd_seed;    // need noisy input

	// ===== Combinational Circuits =====
	PRNG prng_0(.rst_n(i_rst_n), .seed(rnd_seed), .gen(rnd_gen), .random_num(o_random_out_nxt));

	// FSM
	always_comb begin
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
		cycle_nxt   = cycle;
		counter_nxt = counter;
		rnd_gen_nxt = 1'b0;

		case (state)
			S_IDLE: begin
				cycle_nxt = 4'b0;
			end
			S_PROC: begin
				if (counter[24:21] == cycle) begin
					cycle_nxt   = cycle + 4'd1;
					counter_nxt = 25'd0;
					rnd_gen_nxt = 1'b1;
				end
				else begin
					counter_nxt = counter + 1;
				end
			end
			default: begin
				cycle_nxt   =  4'd1;
				counter_nxt = 25'd0;
				rnd_gen_nxt =  1'b0;
			end
		endcase
	end

	// ===== Sequential Circuits =====
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		// reset
		if (!i_rst_n) begin
			state	     <= S_IDLE;
			o_random_out <= 4'd0;
			cycle        <= 4'd1;
			counter      <= 25'd0;
			rnd_gen      <= 1'b0;
		end
		else begin
			state 		 <= state_nxt;
			o_random_out <= o_random_out_nxt;
			cycle        <= cycle_nxt;
			counter      <= counter_nxt;
			rnd_gen      <= rnd_gen_nxt;
		end
	end

endmodule

module PRNG(
	input         rst_n,
	input  [15:0] seed,
	input         gen,
	output [3:0]  random_num
);
	// wire and registers
	logic [14:0] seq1, seq1_nxt;
	logic [10:0] seq2, seq2_nxt;
	logic [9:0]  seq3, seq3_nxt;
	logic [8:0]  seq4, seq4_nxt;

	assign random_num = {seq4[0], seq2[0], seq3[0], seq1[0]};
	
	always_comb begin
		seq1_nxt = {seq1[0],            seq1[0]^seq1[14], seq1[13:1]};    // 15: 13, 14
		seq2_nxt = {seq2[0], seq2[ 10], seq2[0]^seq2[ 9], seq2[ 8:1]};    // 11:  8, 10
		seq3_nxt = {seq3[0], seq3[9:8], seq3[0]^seq3[ 7], seq3[ 6:1]};    // 10:  6,  9
		seq4_nxt = {seq4[0], seq4[8:6], seq4[0]^seq4[ 5], seq4[ 4:1]};    //  9:  4,  8
	end

	// assign nxt
	always_ff @(posedge gen or negedge rst_n) begin
		// reset
		if (!rst_n) begin
			seq1 <= {seed[ 9: 5], seed[15: 7], 1'b0};
			seq2 <= {seed[13:12], seed[ 7: 0], 1'b0};
			seq3 <= {seed[ 9: 4], seed[14:12], 1'b0};
			seq4 <= {seed[ 6: 3], seed[ 8: 5], 1'b0};
		end
		else begin
			seq1 <= seq1_nxt;
			seq2 <= seq2_nxt;
			seq3 <= seq3_nxt;
			seq4 <= seq4_nxt;
		end
	end
	
endmodule
