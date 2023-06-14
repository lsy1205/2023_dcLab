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
logic [19:0] new_addr_r[0:3], new_addr_w[0:3]; // 0:U, 1:L, 2:D, 3:R
logic [7:0]  pix_cntr_r, pix_cntr_w;
logic [19:0] last_ul_addr_r, last_ul_addr_w;
logic [19:0] last_ur_addr_r, last_ur_addr_w;
logic [19:0] last_dl_addr_r, last_dl_addr_w;
logic [19:0] last_dr_addr_r, last_dr_addr_w;
logic        valid_r, valid_w;
logic        last_success_r, last_success_w;
logic [10:0] d_ul[0:3], d_ul_row[0:3], d_ul_col[0:3]; // 0:U, 1:L, 2:D, 3:R
logic [10:0] d_ur[0:3], d_ur_row[0:3], d_ur_col[0:3]; // 0:U, 1:L, 2:D, 3:R
logic [10:0] d_dl[0:3], d_dl_row[0:3], d_dl_col[0:3]; // 0:U, 1:L, 2:D, 3:R
logic [10:0] d_dr[0:3], d_dr_row[0:3], d_dr_col[0:3]; // 0:U, 1:L, 2:D, 3:R
logic [1:0]  min_index[0:3][0:2];


assign o_valid = valid_r;
assign o_success = last_success_r;
assign o_ul_addr = last_ul_addr_r;
assign o_ur_addr = last_ur_addr_r;
assign o_dl_addr = last_dl_addr_r;
assign o_dr_addr = last_dr_addr_r;

genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin : distance
        assign d_ul_row[i] = new_addr_r[i][19:10] - last_ul_addr_r[19:10];
        assign d_ur_row[i] = new_addr_r[i][19:10] - last_ur_addr_r[19:10];
        assign d_dl_row[i] = new_addr_r[i][19:10] - last_dl_addr_r[19:10];
        assign d_dr_row[i] = new_addr_r[i][19:10] - last_dr_addr_r[19:10];

        assign d_ul_col[i] = new_addr_r[i][ 9: 0] - last_ul_addr_r[ 9: 0];
        assign d_ur_col[i] = new_addr_r[i][ 9: 0] - last_ur_addr_r[ 9: 0];
        assign d_dl_col[i] = new_addr_r[i][ 9: 0] - last_dl_addr_r[ 9: 0];
        assign d_dr_col[i] = new_addr_r[i][ 9: 0] - last_dr_addr_r[ 9: 0];
        
        assign d_ul[i] = (d_ul_row[i][10] ? -d_ul_row[i] : d_ul_row[i]) + (d_ul_col[i][10] ? -d_ul_col[i] : d_ul_col[i]);
        assign d_ur[i] = (d_ur_row[i][10] ? -d_ur_row[i] : d_ur_row[i]) + (d_ur_col[i][10] ? -d_ur_col[i] : d_ur_col[i]);
        assign d_dl[i] = (d_dl_row[i][10] ? -d_dl_row[i] : d_dl_row[i]) + (d_dl_col[i][10] ? -d_dl_col[i] : d_dl_col[i]);
        assign d_dr[i] = (d_dr_row[i][10] ? -d_dr_row[i] : d_dr_row[i]) + (d_dr_col[i][10] ? -d_dr_col[i] : d_dr_col[i]);
    end
endgenerate

assign min_index[0][0] = (d_ul[0] < d_ul[1]) ? 0 : 1;
assign min_index[0][1] = (d_ul[2] < d_ul[3]) ? 2 : 3;
assign min_index[0][2] = (d_ul[min_index[0][0]] < d_ul[min_index[0][1]]) ? min_index[0][0] : min_index[0][1];

assign min_index[1][0] = (d_ur[0] < d_ur[1]) ? 0 : 1;
assign min_index[1][1] = (d_ur[2] < d_ur[3]) ? 2 : 3;
assign min_index[1][2] = (d_ur[min_index[1][0]] < d_ur[min_index[1][1]]) ? min_index[1][0] : min_index[1][1];

assign min_index[2][0] = (d_dl[0] < d_dl[1]) ? 0 : 1;
assign min_index[2][1] = (d_dl[2] < d_dl[3]) ? 2 : 3;
assign min_index[2][2] = (d_dl[min_index[2][0]] < d_dl[min_index[2][1]]) ? min_index[2][0] : min_index[2][1];

assign min_index[3][0] = (d_dr[0] < d_dr[1]) ? 0 : 1;
assign min_index[3][1] = (d_dr[2] < d_dr[3]) ? 2 : 3;
assign min_index[3][2] = (d_dr[min_index[3][0]] < d_dr[min_index[3][1]]) ? min_index[3][0] : min_index[3][1];

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    new_addr_w[0] = new_addr_r[0];
    new_addr_w[3] = new_addr_r[3];
    new_addr_w[1] = new_addr_r[1];
    new_addr_w[2] = new_addr_r[2];
    pix_cntr_w = pix_cntr_r;
    last_success_w = last_success_r;
    last_ul_addr_w = last_ul_addr_r;
    last_ur_addr_w = last_ur_addr_r;
    last_dl_addr_w = last_dl_addr_r;
    last_dr_addr_w = last_dr_addr_r;
    valid_w = 0;

    if (i_valid) begin
        if (col_counter_r != 799) begin
            col_counter_w = col_counter_r + 1;
        end
        else begin
            col_counter_w = 0;
            if(row_counter_r != 599) begin
                row_counter_w = row_counter_r + 1;
            end 
            else begin
                row_counter_w = 0;
                valid_w = 1;

                if (&pix_cntr_r) begin
                    last_success_w = 1;
                    last_ul_addr_w = new_addr_r[0];  // new_addr_r[min_index[0][2]];
                    last_ur_addr_w = new_addr_r[1];  // new_addr_r[min_index[1][2]];
                    last_dl_addr_w = new_addr_r[2];  // new_addr_r[min_index[2][2]];
                    last_dr_addr_w = new_addr_r[3];  // new_addr_r[min_index[3][2]];
                end
                else begin
                    last_success_w = 0;
                    last_ul_addr_w = {10'd0, 10'd0};
                    last_ur_addr_w = {10'd0, 10'd799};
                    last_dl_addr_w = {10'd599, 10'd0};
                    last_dr_addr_w = {10'd599, 10'd799};
                end
            end
        end
    end

    if (row_counter_r == 0 && col_counter_r == 0) begin
        new_addr_w[0] = {10'd599, 10'd799};
        new_addr_w[3] = {10'd599, 10'd0};
        new_addr_w[1] = {10'd0, 10'd799};
        new_addr_w[2] = {10'd0, 10'd0};
        pix_cntr_w = 8'b0;
    end
    else if (i_data) begin
        if (row_counter_r < new_addr_r[0][19:10]) begin
            new_addr_w[0] = {row_counter_r, col_counter_r};
        end
        if (!(row_counter_r < new_addr_r[2][19:10])) begin
            new_addr_w[2] = {row_counter_r, col_counter_r};
        end
        if (!(col_counter_r > new_addr_r[1][9:0])) begin
            new_addr_w[1] = {row_counter_r, col_counter_r};
        end
        if (col_counter_r > new_addr_r[3][9:0]) begin
            new_addr_w[3] = {row_counter_r, col_counter_r};
        end
        if (!(&pix_cntr_r)) begin
            pix_cntr_w = pix_cntr_r + 1;
        end
    end


end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r  <= 0;
        col_counter_r  <= 0;
        pix_cntr_r     <= 0;
        new_addr_r[0]  <= {10'd599, 10'd799};
        new_addr_r[1]  <= {10'd0, 10'd799};
        new_addr_r[2]  <= {10'd0, 10'd0};
        new_addr_r[3]  <= {10'd599, 10'd0};
        last_success_r <= 0;
        valid_r        <= 0;
        last_ul_addr_r <= {10'd0, 10'd0};
        last_ur_addr_r <= {10'd0, 10'd799};
        last_dl_addr_r <= {10'd599, 10'd0};
        last_dr_addr_r <= {10'd599, 10'd799};
    end
    else begin
        row_counter_r  <= row_counter_w;
        col_counter_r  <= col_counter_w;
        pix_cntr_r     <= pix_cntr_w;
        new_addr_r[0]  <= new_addr_w[0];
        new_addr_r[1]  <= new_addr_w[1];
        new_addr_r[2]  <= new_addr_w[2];
        new_addr_r[3]  <= new_addr_w[3];
        last_success_r <= last_success_w;
        valid_r        <= valid_w;
        last_ul_addr_r <= last_ul_addr_w;
        last_ur_addr_r <= last_ur_addr_w;
        last_dl_addr_r <= last_dl_addr_w;
        last_dr_addr_r <= last_dr_addr_w;
    end
end

endmodule
