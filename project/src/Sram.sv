module Sram (
	input         i_clk,
	input         i_rst_n,
	input         i_clear,
	input         i_mode, // 0: read, 1: write
	input   [2:0] i_next_num,
	input         i_start,
	output        o_fin,

	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,

	output        o_vaild,
	output [15:0] o_r_data,
	input  [15:0] i_w_data
);

localparam S_IDLE  = 0;
localparam S_FETCH = 1;

logic        state_r, state_w;
logic        fin_r, fin_w;
logic        valid_r, valid_w;
logic [19:0] data_length_r, data_length_w;

logic [20:0] addr_now_r, addr_now_w;
logic        we_n_r, we_n_w;
logic [15:0] read_data_r, read_data_w;
logic [15:0] write_data_r, write_data_w;

assign o_SRAM_ADDR = addr_now_r[19:0];
assign io_SRAM_DQ  = (we_n_r) ? 16'dz : write_data_r; // sram_dq as output
assign o_r_data    = read_data_r;
assign o_SRAM_WE_N = we_n_r;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign o_fin   = fin_r;
assign o_vaild = valid_r;

always_comb begin
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			if (i_start && valid_w)
				state_w = S_FETCH;
		end
		S_FETCH: begin
			state_w = S_IDLE;
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin
	data_length_w = data_length_r;
	addr_now_w    = addr_now_r;
	write_data_w = write_data_r;
	read_data_w   = read_data_r;
	valid_w = 0;
	we_n_w  = 1;
	fin_w   = 0;

	case (state_r)
		S_IDLE: begin 
			valid_w = 0;
			if (i_start) begin
				addr_now_w = ( addr_now_r + 1 ) + 
							 ( (!i_mode && addr_now_r != 21'h1fffff) ? i_next_num : 0 );
				
				if (i_mode) begin                 // write to memory
					if (addr_now_w[20]) begin
						fin_w = 1;
					end
					else begin
						valid_w       = 1;
						we_n_w        = 0;
						write_data_w = i_w_data;
						data_length_w = addr_now_w;
					end
				end
				else begin                       // read from memory
					if (addr_now_w[20] || addr_now_w > data_length_r) begin
						fin_w = 1;
					end
					else begin
						valid_w = 1;
					end
				end
			end
		end 
		S_FETCH: begin
			if(i_mode) begin          // write to memory
				valid_w = 1;
				fin_w   = 1;
			end
			else begin               // read from memory
				read_data_w = io_SRAM_DQ; // sram_dq as input
				valid_w = 1;
				fin_w   = 1;
			end
		end
		default: begin
			data_length_w = data_length_r;
			addr_now_w    = addr_now_r;
			write_data_w = write_data_r;
			read_data_w   = read_data_r;
			valid_w = 0;
			we_n_w  = 1;
			fin_w   = 0;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n)begin
	if (!i_rst_n) begin
		state_r       <= S_IDLE;
		data_length_r <= 0;
		addr_now_r    <= 21'h1fffff;
		write_data_r <= 0;
		read_data_r   <= 0;
		valid_r       <= 0;
		we_n_r        <= 1;
		fin_r         <= 0;
	end
	else begin
		if (i_clear) begin
			state_r       <= S_IDLE;
			data_length_r <= data_length_w;
			addr_now_r    <= 21'h1fffff;
			write_data_r <= 0;
			read_data_r   <= 0;
			valid_r       <= 0;
			we_n_r        <= 1;
			fin_r         <= 0;
		end
		else begin
			state_r       <= state_w;
			data_length_r <= data_length_w;
			addr_now_r    <= addr_now_w;
			write_data_r  <= write_data_w;
			read_data_r   <= read_data_w;
			valid_r       <= valid_w;
			we_n_r        <= we_n_w;
			fin_r         <= fin_w;			
		end
	end
end
    
endmodule
