module Sram_Contoller (
    input         i_clk,
    input         i_rst_n,

    input  [15:0] wr_data,
    input         wr_request,
    input         wr_rst,
    input         wr_clk,
    input         wr_finished,
    output        o_finish,

    output [15:0] rd_data,
    input         rd_request,
    input         rd_rst,
    input         rd_clk,


    output [19:0] o_SRAM_ADDR,
    inout  [15:0] io_SRAM_DQ,
    output        o_SRAM_WE_N,
    output        o_SRAM_CE_N,
    output        o_SRAM_OE_N,
    output        o_SRAM_LB_N,
    output        o_SRAM_UB_N
);

localparam   addr1_start = 0;
localparam   addr2_start = 800*600;

logic [19:0] addr;
logic [19:0] write_addr_r, write_addr_w;
logic [19:0] read_addr_r, read_addr_w;
logic [15:0] write_sdram_data;
logic [7:0]  write_side_fifo_rusedw, read_side_fifo_wusedw;
logic        write_side_req_r, write_side_req_w;
logic        read_side_req_r, read_side_req_w;

assign addr = (write_side_req_r) ? write_addr_r : read_addr_r;

assign o_SRAM_ADDR = addr;
assign io_SRAM_DQ  = (write_side_req_r) ? write_sdram_data : 16'bz; // sram_dq as output
assign o_SRAM_WE_N = ~write_side_req_r;
assign o_SRAM_CE_N = ~(read_side_req_r | write_side_req_r);
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

Sram_WR_FIFO  write_fifo (
    .data(wr_data),
    .wrreq(wr_request),
    .wrclk(wr_clk),
    .aclr(~i_rst_n),
    .rdreq(write_side_req_w), 
    .rdclk(i_clk),
    .q(write_sdram_data),
    .rdusedw(write_side_fifo_rusedw)
);
        
Sdram_RD_FIFO  u_read2_fifo (
    .data(io_SRAM_DQ),
    .wrreq(read_side_req_r),
    .wrclk(i_clk),
    .aclr(~i_rst_n),
    .rdreq(rd_request),
    .rdclk(rd_clk),
    .q(rd_data),
    .wrusedw(read_side_fifo_wusedw)
);

always_comb begin
    write_addr_w = write_addr_r;
    read_addr_w = read_addr_r;
    write_side_req_w = write_side_req_r;
    read_side_req_w = read_side_req_r;

    if (read_side_fifo_wusedw < 255 && write_side_fifo_rusedw > 0) begin
        
    end

end
always_ff @(posedge i_clk or negedge i_rst_n)begin
    if (!i_rst_n) begin
        write_addr_r       <= 0;
        read_addr_r        <= 0;
        write_side_req_r   <= 0;
        read_side_req_r    <= 0;
    end
    else begin
        write_addr_r       <= write_addr_w;
        read_addr_r        <= read_addr_w;
        write_side_req_r   <= write_side_req_w;
        read_side_req_r    <= read_side_req_w;
    end
end
    
endmodule
