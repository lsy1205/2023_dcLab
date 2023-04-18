module Mem (
    input         i_clk,
    input         i_rst_n,
    input         i_mode, // 0: play(read), 1: record(write)
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

    input  [15:0] i_w_data,
    output        o_vaild,
    output [15:0] o_r_data
);

localparam S_IDLE = 0;
localparam S_FETCH = 1;

logic state_r, state_w;
logic o_we_n_r, o_we_n_w;
logic o_valid_r, o_valid_w;
logic [19:0] data_length_r, data_length_w;
logic [20:0] addr_now_r, addr_now_w;
logic [15:0] record_data_r, record_data_w;

assign o_SRAM_ADDR = addr_now_r;
assign io_SRAM_DQ  = ( i_mode) ? record_data_r : 16'dz; // sram_dq as output
assign o_r_data    = (!i_mode ) ?  io_SRAM_DQ : 16'd0; // sram_dq as input
assign o_SRAM_WE_N = o_we_n_r;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

always_comb begin
    state_w = state_r;
    case (state_r)
        S_IDLE: begin
			if(i_start) state_w = S_FETCH;
			else        state_w = S_IDLE;
        end 
		S_FETCH: begin
			state_w = S_IDLE;
		end
        default: begin
			state_w = state_r;
		end
    endcase
end

always_comb begin
	addr_now_w    = addr_now_r;
	data_length_w = data_length_r;
	record_data_w = record_data_r;
	o_we_n_w      = o_we_n_r;
	o_valid_w     = o_valid_r;
	o_fin_w       = 0;
    case (state_r)
        S_IDLE: begin 
			o_valid_w = 0;
			if(i_start) begin
				if(i_mode) begin                 // write to memory
					addr_now_w = addr_now_r + 1;
					if(addr_now_w[20]) o_vaild_w = 0;
					else begin
						o_we_n_w      = 0;	
						o_vaild_w     = 1;
						record_data_w = i_w_data;
						data_length_w = data_length_r + 1;
					end
				end
				else begin                       // read from memory
					addr_now_w = (addr_now_r == 21'h1fffff) ? addr_now_r + 1 : addr_now_r + (i_next_num + 1);
					if(addr_now_w[20] || addr_now_w >= data_length_r) o_valid_w = 0;
					else begin
						o_valid_w = 1;
					end
				end
			end
			else begin
				
			end
        end 
		S_FETCH: begin
			if(i_mode) begin          // write to memory
				if(o_valid_r) begin
					o_valid_w = 1;
					o_fin_w   = 1;
					o_we_n_w  = 1;
				end
				else begin
					o_valid_w = 0;
					o_we_n_w  = 0;
					o_fin_w   = 1; 
				end		
			end
			else begin 		         // read from memory
				o_fin_w = 1;			
				if(o_valid_r) begin
					o_valid_w = 1;
				end
				else begin
					o_vaild_w = 0;
				end
			end
		end
        default: begin
			addr_now_w    = addr_now_r;
			data_length_w = data_length_r;
			record_data_w = record_data_r;
			o_we_n_w      = o_we_n_r;
			o_valid_w     = o_valid_r;
			o_fin_w       = 0;
		end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n || i_clear) begin
		state_r       <= S_IDLE;
		o_we_n_r      <= 1;
		o_valid_r     <= 0;
		addr_now_r    <= 0;
		record_data_r <= 0;
		addr_now_r    <= 0;
		data_length_r <= (i_clear) ? data_length_w : 21'h1fffff;
	end
	else begin
		state_r       <= state_w;
		o_we_n_r      <= o_we_n_w;
		o_valid_r     <= o_valid_w;
		data_length_r <= data_length_w;
		addr_now_r    <= addr_now_w;
		record_data_r <= record_data_w;
	end
end
    
endmodule
