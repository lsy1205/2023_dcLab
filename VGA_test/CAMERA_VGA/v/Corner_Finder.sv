module Corner_Finder (
    input  i_clk,
    input  i_rst_n,
    input  i_data,
    input  i_valid,
    output o_valid,
    output o_success,
    output [19:0] o_ul_addr, // first 10 bit is row, last is col
    output [19:0] o_ur_addr,
    output [19:0] o_dl_addr,
    output [19:0] o_dr_addr
);

logic [9:0]  row_counter_r, row_counter_w;
logic [9:0]  col_counter_r, col_counter_w;
logic [19:0] ul_addr_r, ul_addr_w;
logic [19:0] ur_addr_r, ur_addr_w;
logic [19:0] dl_addr_r, dl_addr_w;
logic [19:0] dr_addr_r, dr_addr_w;
logic [7:0]  pix_cntr_r, pix_cntr_w;

assign o_valid = (row_counter_r == 599 && col_counter_r == 799);
assign o_success = &pix_cntr_r; 
assign o_ul_addr = ul_addr_r;
assign o_ur_addr = ur_addr_r;
assign o_dl_addr = dl_addr_r;
assign o_dr_addr = dr_addr_r;

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    ul_addr_w = ul_addr_r;
    ur_addr_w = ur_addr_r;
    dl_addr_w = dl_addr_r;
    dr_addr_w = dr_addr_r;
    pix_cntr_w = pix_cntr_r;

    if (i_valid) begin
        if (col_counter_r == 799) begin
            col_counter_w = 0;
            if(row_counter_r == 599) begin
                row_counter_w = 0;
            end 
            else begin
                row_counter_w = row_counter_r + 1;
            end
        end
        else begin
            col_counter_w = col_counter_r + 1;
        end
    end
    if (row_counter_r == 0 && col_counter_r == 0) begin
        ul_addr_w = {10'd599, 10'd799};
        ur_addr_w = {10'd599, 10'd0};
        dl_addr_w = {10'd0, 10'd799};
        dr_addr_w = {10'd0, 10'd0};
        pix_cntr_w = 8'b0;
    end
    else if (i_data) begin
        if (row_counter_r < ul_addr_r[19:10]) begin
            ul_addr_w = {row_counter_r, col_counter_r};
        end
        if (!(row_counter_r < dr_addr_r[19:10])) begin
            dr_addr_w = {row_counter_r, col_counter_r};
        end
        if (!(col_counter_r > dl_addr_r[9:0])) begin
            dl_addr_w = {row_counter_r, col_counter_r};
        end
        if (col_counter_r > ur_addr_r[9:0]) begin
            ur_addr_w = {row_counter_r, col_counter_r};
        end
        if (!(&pix_cntr_r)) begin
            pix_cntr_w = pix_cntr_r + 1;
        end
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r <= 0;
        col_counter_r <= 0;
        pix_cntr_r    <= 0;
        ul_addr_r     <= {10'd599, 10'd799};
        ur_addr_r     <= {10'd599, 10'd0};
        dl_addr_r     <= {10'd0, 10'd799};
        dr_addr_r     <= {10'd0, 10'd0};
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        pix_cntr_r    <= pix_cntr_w;
        ul_addr_r     <= ul_addr_w;
        ur_addr_r     <= ur_addr_w;
        dl_addr_r     <= dl_addr_w;
        dr_addr_r     <= dr_addr_w;
    end
end

endmodule
