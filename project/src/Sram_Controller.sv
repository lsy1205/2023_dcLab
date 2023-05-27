module Sram_Contoller (
    input         i_clk,
    input         i_rst_n,
    input         i_write,
    input         i_read,
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

logic        fin_r, fin_w;
logic        valid_r, valid_w;

logic [20:0] addr_now_r, addr_now_w;
logic        we_n_r, we_n_w;
logic [15:0] read_data_r, read_data_w;
logic [15:0] write_data_r, write_data_w;

assign o_SRAM_ADDR = addr_now_r[19:0];
assign io_SRAM_DQ  = (we_n_r) ? 16'dz : write_data_r; // sram_dq as output
assign o_r_data    = read_data_r;
assign o_SRAM_WE_N = ~i_write;
assign o_SRAM_CE_N = ~(i_read | i_write);
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign o_fin   = fin_r;
assign o_vaild = valid_r;

always_comb begin
    addr_now_w    = addr_now_r;
    write_data_w = write_data_r;
    read_data_w   = read_data_r;
    valid_w = 0;
    we_n_w  = 1;
    fin_w   = 0;

    if (i_write) begin
        valid_w = 1;
        if (addr_now_r == 12287) begin
            addr_now_w = 0;
            fin_w = 1;
        end
        else begin
            we_n_w        = 0;
            write_data_w  = i_w_data;
            addr_now_w = addr_now_r + 1;
        end
    end
    if (i_read) begin                       // read from memory
        valid_w = 1;
        read_data_w = io_SRAM_DQ; // sram_dq as input
        if (addr_now_r == 12287) begin
            addr_now_w = 0;
            fin_w = 1;
        end
        else begin
            addr_now_w = addr_now_r + 1;
        end
    end 
end

always_ff @(posedge i_clk or negedge i_rst_n)begin
    if (!i_rst_n) begin
        addr_now_r    <= 0;
        write_data_r  <= 0;
        read_data_r   <= 0;
        valid_r       <= 0;
        we_n_r        <= 1;
        fin_r         <= 0;
    end
    else begin
        addr_now_r    <= addr_now_w;
        write_data_r  <= write_data_w;
        read_data_r   <= read_data_w;
        valid_r       <= valid_w;
        we_n_r        <= we_n_w;
        fin_r         <= fin_w;            
    end
end
    
endmodule
