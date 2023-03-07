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
	logic [3:0] o_random_out_r, o_random_out_w;

	// ===== Registers & Wires =====
	logic        state, state_nxt;
	logic [3:0]  cycle, cycle_nxt;
	logic        rnd_gen, rnd_gen_nxt;
	logic [24:0] counter, counter_nxt;
	logic [15:0] rnd_seed = 16'haf15;		// need noisy input

	// ===== Output Assignments =====
	assign o_random_out = o_random_out_r;

	// ===== Combinational Circuits =====
	PRNG prng_0(.rst_n(i_rst_n), .seed(rnd_seed), .gen(rnd_gen), .random_num(o_random_out_w));


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
					cycle_nxt   = cycle + 4'b1;
					counter_nxt = 25'b0;
					rnd_gen_nxt = 1'b1;
				end
				else begin
					counter_nxt = counter + 1;
				end
			end
			default: begin
				cycle_nxt   =  4'b0;
				counter_nxt = 25'b0;
				rnd_gen_nxt =  1'b0;
			end
		endcase
	end

	// ===== Sequential Circuits =====
	always_ff @(posedge i_clk or negedge i_rst_n) begin
		// reset
		if (!i_rst_n) begin
			o_random_out_r <= 4'b0;
			state	       <= S_IDLE;
			cycle          <= 4'b0;
			counter        <= 25'b0;
			rnd_gen        <= 1'b0;
		end
		else begin
			o_random_out_r <= o_random_out_w;
			state 		   <= state_nxt;
			cycle          <= cycle_nxt;
			counter        <= counter_nxt;
			rnd_gen        <= rnd_gen_nxt;
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

	assign random_num = {seq4[0], seq3[0], seq2[0], seq1[0]};
	
	always_comb begin
		seq1_nxt = {seq1[0],            seq1[0]^seq1[14], seq1[13:1]};
		seq2_nxt = {seq2[0], seq2[10] , seq2[0]^seq2[9] ,  seq2[8:1]};
		seq3_nxt = {seq3[0], seq3[9:8], seq3[0]^seq3[7] ,  seq3[6:1]};
		seq4_nxt = {seq4[0], seq4[8:6], seq4[0]^seq4[5] ,  seq4[4:1]};

	end
	// assign nxt
	always_ff @(posedge gen or negedge rst_n) begin
		// reset
		if (!rst_n) begin
			seq1 <= {seed[15:2], 1'b0};
			seq2 <= {seed[10:1], 1'b0};
			seq3 <= {seed[12:4], 1'b0};
			seq4 <= {seed[14:7], 1'b0};
		end
		else begin
			seq1 <= seq1_nxt;
			seq2 <= seq2_nxt;
			seq3 <= seq3_nxt;
			seq4 <= seq4_nxt;
		end
	end
	
endmodule


// 15 : 13 14
// 11 :  8 10
// 10 :  6  9
// 9  :  4  8
