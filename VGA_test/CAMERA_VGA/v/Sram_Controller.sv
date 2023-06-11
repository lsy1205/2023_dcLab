module Sram_Contoller (
    input         i_clk,
    input         i_rst_n,

    input  [15:0] wr_data,
    input         wr_request,
    input         wr_clk,

    output [15:0] rd_data,
    input         rd_request,
    input         rd_clk,


    output [19:0] o_SRAM_ADDR,
    inout  [15:0] io_SRAM_DQ,
    output        o_SRAM_WE_N,
    output        o_SRAM_CE_N,
    output        o_SRAM_OE_N,
    output        o_SRAM_LB_N,
    output        o_SRAM_UB_N,

    output        o_rd_use,
    output        o_wr_use
);

localparam   addr1_start = 20'd0;
// localparam   addr2_start = 20'd500_000;
localparam   addr2_start = 20'd0;
localparam   addr1_end = 20'd479_999;  // 800*600;
// localparam   addr2_end = 20'd980_000;  // 500_000 + 800*600;
localparam   addr2_end = 20'd479_999;  // 500_000 + 800*600;

localparam S_IDLE  = 0;
localparam S_WRITE = 1;
localparam S_READ  = 2;
localparam S_RTOW  = 3;

logic [19:0] write_addr_r, write_addr_w;
logic [19:0] read_addr_r, read_addr_w;
logic [15:0] write_sdram_data;
logic [7:0]  write_side_fifo_rusedw, read_side_fifo_wusedw;
logic        write_side_req;
logic        read_side_req_r, read_side_req_w;
logic [1:0]  state_r, state_w;
logic        change_r, change_w;
logic        wen, ren;

logic [29:0] test_counter_r, test_counter_w;
logic [15:0] test_data;

assign wen = (state_r == S_WRITE);
assign ren = (state_r == S_READ);

assign o_SRAM_ADDR = (wen) ? write_addr_r : read_addr_r;
assign io_SRAM_DQ  = (wen) ? write_sdram_data : 16'bz; // sram_dq as output
assign o_SRAM_WE_N = ~wen;
assign o_SRAM_CE_N = ~(ren | wen);
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// assign test_data = 16'b0;
assign test_data = test_counter_r[29] ? 16'hffff : 16'b0;
assign o_rd_use = read_side_fifo_wusedw < 10;
assign o_wr_use = write_side_fifo_rusedw > 250;

// SRAM_WR_FIFO  write_fifo (
//     .data(test_data),
//     .wrreq(wr_request),
//     .wrclk(wr_clk),
//     .aclr(~i_rst_n),
//     .rdreq(write_side_req), 
//     .rdclk(i_clk),
//     .q(write_sdram_data),
//     .rdusedw(write_side_fifo_rusedw)
// );

SRAM_WR_FIFO  write_fifo (
    .data(wr_data),
    .wrreq(wr_request),
    .wrclk(wr_clk),
    .aclr(~i_rst_n),
    .rdreq(write_side_req), 
    .rdclk(i_clk),
    .q(write_sdram_data),
    .rdusedw(write_side_fifo_rusedw)
);
        
SRAM_RD_FIFO  read_fifo (
    .data(io_SRAM_DQ),
    .wrreq(read_side_req_r),
    .wrclk(i_clk),
    .aclr(~i_rst_n),
    .rdreq(rd_request),
    .rdclk(rd_clk),
    .q(rd_data),
    .wrusedw(read_side_fifo_wusedw)
);

// SRAM_RD_FIFO  read_fifo (
//     .data(test_data),
//     .wrreq(read_side_req_r),
//     .wrclk(i_clk),
//     .aclr(~i_rst_n),
//     .rdreq(rd_request),
//     .rdclk(rd_clk),
//     .q(rd_data),
//     .wrusedw(read_side_fifo_wusedw)
// );

always_comb begin : FSM
    state_w = state_r;

    case(state_r)
        S_IDLE: begin
            if (!read_side_fifo_wusedw[7]) begin    // < 128
                state_w = S_READ;
            end
            else if (&write_side_fifo_rusedw[7:4]) begin    // >= 240
                state_w = S_WRITE;
            end
            else if (!(&read_side_fifo_wusedw[7:6])) begin      // < 192
                state_w = S_READ;
            end
            else if (write_side_fifo_rusedw[7] && write_side_fifo_rusedw[6:5]) begin    // >= 160
                state_w = S_WRITE;
            end
            else begin
                state_w = S_IDLE;
            end
        end
        S_WRITE: begin
            if (!write_side_fifo_rusedw[7] || !(write_side_fifo_rusedw[6:5])) begin     // < 160
                if (!read_side_fifo_wusedw[7]) begin
                    state_w = S_READ;
                end
                else if (!write_side_fifo_rusedw[7:6]) begin   // < 64
                    state_w = S_IDLE;
                end
            end
            else begin
                state_w = S_WRITE;
            end
        end
        S_READ: begin
            if (&read_side_fifo_wusedw[7:6]) begin      // >= 192
                if (&write_side_fifo_rusedw[7:4]) begin
                    state_w = S_RTOW;
                end
                else if (&read_side_fifo_wusedw[7:4]) begin     // >= 240
                    state_w = S_IDLE;
                end
            end
            else begin
                state_w = S_READ;
            end
        end
        S_RTOW: begin
            state_w = S_WRITE;
        end
    endcase
end

always_comb begin
    write_addr_w = write_addr_r;
    read_addr_w = read_addr_r;
    write_side_req = (state_w == S_WRITE);
    read_side_req_w = 0;
    change_w = change_r;

    test_counter_w = test_counter_r + 1;

    case(state_r)
        S_WRITE: begin
            if (write_addr_r != addr1_end && write_addr_r != addr2_end) begin
                write_addr_w = write_addr_r + 1;
            end
            else begin
                write_addr_w = (write_addr_r == addr1_end) ? addr2_start : addr1_start;
                change_w = 1;
            end
        end
        S_READ: begin
            read_side_req_w = 1;
            if (read_addr_r != addr1_end && read_addr_r != addr2_end) begin
                read_addr_w = read_addr_r + 1;
            end
            else begin
                if (change_r) begin
                    read_addr_w = (read_addr_r == addr1_end) ? addr2_start : addr1_start;
                    change_w = 0;
                end
                else begin
                    read_addr_w = (read_addr_r == addr1_end) ? addr1_start : addr2_start;
                end
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n)begin
    if (!i_rst_n) begin
        state_r          <= S_WRITE;
        write_addr_r     <= addr1_start;
        read_addr_r      <= addr2_start;
        read_side_req_r  <= 0;
        change_r         <= 0;
        test_counter_r   <= 0;
    end
    else begin
        state_r          <= state_w;
        write_addr_r     <= write_addr_w;
        read_addr_r      <= read_addr_w;
        read_side_req_r  <= read_side_req_w;
        change_r         <= change_w;
        test_counter_r   <= test_counter_w;
    end
end
    
endmodule
