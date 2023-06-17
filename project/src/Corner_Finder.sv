module Corner_Finder (
    input  i_clk,
    input  i_rst_n,
    input  i_data,
    input  i_valid,
    output o_valid,
    output o_success,
    output [19:0] o_ul_addr,    // {row, col}
    output [19:0] o_ur_addr,    // {row, col}
    output [19:0] o_dl_addr,    // {row, col}
    output [19:0] o_dr_addr     // {row, col}
);

logic [ 9:0] row_counter_r, row_counter_w;
logic [ 9:0] col_counter_r, col_counter_w;
logic [19:0] new_addr_r[0:3], new_addr_w[0:3]; // 0:U, 1:L, 2:D, 3:R
logic [ 7:0] pix_cntr_r, pix_cntr_w;
logic [19:0] last_ul_addr_r[0:3], last_ul_addr_w[0:3];
logic [19:0] last_ur_addr_r[0:3], last_ur_addr_w[0:3];
logic [19:0] last_dl_addr_r[0:3], last_dl_addr_w[0:3];
logic [19:0] last_dr_addr_r[0:3], last_dr_addr_w[0:3];
logic [11:0] sum_ul_row, sum_ur_row, sum_dl_row, sum_dr_row;
logic [11:0] sum_ul_col, sum_ur_col, sum_dl_col, sum_dr_col;
logic        valid_r, valid_w;
logic        last_success_r, last_success_w;
logic        miss_counter_r, miss_counter_w;
// logic [10:0] d_ul[0:3], d_ul_row[0:3], d_ul_col[0:3]; // 0:U, 1:L, 2:D, 3:R
// logic [10:0] d_ur[0:3], d_ur_row[0:3], d_ur_col[0:3]; // 0:U, 1:L, 2:D, 3:R
// logic [10:0] d_dl[0:3], d_dl_row[0:3], d_dl_col[0:3]; // 0:U, 1:L, 2:D, 3:R
// logic [10:0] d_dr[0:3], d_dr_row[0:3], d_dr_col[0:3]; // 0:U, 1:L, 2:D, 3:R
// logic [11:0] diff_ul, diff_ur, diff_dl, diff_dr;
// logic [ 1:0] min_index[0:3][0:2];
// logic        found, too_close, duplicate;

assign o_valid   = valid_r;
assign o_success = last_success_r;

// assign too_close = ( (&diff_ul[11:4] || !diff_ul[11:4]) || (&diff_ur[11:4] || !diff_ur[11:4]) ) || ( (&diff_dl[11:4] || !diff_dl[11:4]) || (&diff_dr[11:4] || !diff_dr[11:4]) );
// assign duplicate = ( (min_index[0][2] == min_index[1][2] || min_index[0][2] == min_index[2][2]) || (min_index[0][2] == min_index[3][2] || min_index[1][2] == min_index[2][2]) )
//                     || (min_index[1][2] == min_index[3][2] || min_index[2][2] == min_index[3][2]);
// assign found     = &pix_cntr_r && !too_close && !duplicate;

assign sum_ul_row = (last_ul_addr_r[0][19:10] + last_ul_addr_r[1][19:10]) + (last_ul_addr_r[2][19:10] + last_ul_addr_r[3][19:10]);
assign sum_ur_row = (last_ur_addr_r[0][19:10] + last_ur_addr_r[1][19:10]) + (last_ur_addr_r[2][19:10] + last_ur_addr_r[3][19:10]);
assign sum_dl_row = (last_dl_addr_r[0][19:10] + last_dl_addr_r[1][19:10]) + (last_dl_addr_r[2][19:10] + last_dl_addr_r[3][19:10]);
assign sum_dr_row = (last_dr_addr_r[0][19:10] + last_dr_addr_r[1][19:10]) + (last_dr_addr_r[2][19:10] + last_dr_addr_r[3][19:10]);
assign sum_ul_col = (last_ul_addr_r[0][ 9: 0] + last_ul_addr_r[1][ 9: 0]) + (last_ul_addr_r[2][ 9: 0] + last_ul_addr_r[3][ 9: 0]);
assign sum_ur_col = (last_ur_addr_r[0][ 9: 0] + last_ur_addr_r[1][ 9: 0]) + (last_ur_addr_r[2][ 9: 0] + last_ur_addr_r[3][ 9: 0]);
assign sum_dl_col = (last_dl_addr_r[0][ 9: 0] + last_dl_addr_r[1][ 9: 0]) + (last_dl_addr_r[2][ 9: 0] + last_dl_addr_r[3][ 9: 0]);
assign sum_dr_col = (last_dr_addr_r[0][ 9: 0] + last_dr_addr_r[1][ 9: 0]) + (last_dr_addr_r[2][ 9: 0] + last_dr_addr_r[3][ 9: 0]);

assign o_ul_addr = {sum_ul_row[11:2], sum_ul_col[11:2]};
assign o_ur_addr = {sum_ur_row[11:2], sum_ur_col[11:2]};
assign o_dl_addr = {sum_dl_row[11:2], sum_dl_col[11:2]};
assign o_dr_addr = {sum_dr_row[11:2], sum_dr_col[11:2]};

// genvar i;
// generate
//     for (i = 0; i < 4; i = i + 1) begin : distance
//         assign d_ul_row[i] = new_addr_r[i][19:10] - last_ul_addr_r[0][19:10];
//         assign d_ur_row[i] = new_addr_r[i][19:10] - last_ur_addr_r[0][19:10];
//         assign d_dl_row[i] = new_addr_r[i][19:10] - last_dl_addr_r[0][19:10];
//         assign d_dr_row[i] = new_addr_r[i][19:10] - last_dr_addr_r[0][19:10];

//         assign d_ul_col[i] = new_addr_r[i][ 9: 0] - last_ul_addr_r[0][ 9: 0];
//         assign d_ur_col[i] = new_addr_r[i][ 9: 0] - last_ur_addr_r[0][ 9: 0];
//         assign d_dl_col[i] = new_addr_r[i][ 9: 0] - last_dl_addr_r[0][ 9: 0];
//         assign d_dr_col[i] = new_addr_r[i][ 9: 0] - last_dr_addr_r[0][ 9: 0];
        
//         assign d_ul[i] = (d_ul_row[i][10] ? -d_ul_row[i] : d_ul_row[i]) + (d_ul_col[i][10] ? -d_ul_col[i] : d_ul_col[i]);
//         assign d_ur[i] = (d_ur_row[i][10] ? -d_ur_row[i] : d_ur_row[i]) + (d_ur_col[i][10] ? -d_ur_col[i] : d_ur_col[i]);
//         assign d_dl[i] = (d_dl_row[i][10] ? -d_dl_row[i] : d_dl_row[i]) + (d_dl_col[i][10] ? -d_dl_col[i] : d_dl_col[i]);
//         assign d_dr[i] = (d_dr_row[i][10] ? -d_dr_row[i] : d_dr_row[i]) + (d_dr_col[i][10] ? -d_dr_col[i] : d_dr_col[i]);
//     end
// endgenerate

// assign min_index[0][0] = (d_ul[0] < d_ul[1]) ? 0 : 1;
// assign min_index[0][1] = (d_ul[2] < d_ul[3]) ? 2 : 3;
// assign diff_ul         = d_ul[min_index[0][0]] - d_ul[min_index[0][1]];
// assign min_index[0][2] = (diff_ul[11]) ? min_index[0][0] : min_index[0][1];

// assign min_index[1][0] = (d_ur[0] < d_ur[1]) ? 0 : 1;
// assign min_index[1][1] = (d_ur[2] < d_ur[3]) ? 2 : 3;
// assign diff_ur         = d_ur[min_index[1][0]] - d_ur[min_index[1][1]];
// assign min_index[1][2] = (diff_ur[11]) ? min_index[1][0] : min_index[1][1];

// assign min_index[2][0] = (d_dl[0] < d_dl[1]) ? 0 : 1;
// assign min_index[2][1] = (d_dl[2] < d_dl[3]) ? 2 : 3;
// assign diff_dl         = d_dl[min_index[2][0]] - d_dl[min_index[2][1]];
// assign min_index[2][2] = (diff_dl[11]) ? min_index[2][0] : min_index[2][1];

// assign min_index[3][0] = (d_dr[0] < d_dr[1]) ? 0 : 1;
// assign min_index[3][1] = (d_dr[2] < d_dr[3]) ? 2 : 3;
// assign diff_dr         = d_dr[min_index[3][0]] - d_dr[min_index[3][1]];
// assign min_index[3][2] = (diff_dr[11]) ? min_index[3][0] : min_index[3][1];

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    new_addr_w[0] = new_addr_r[0];
    new_addr_w[1] = new_addr_r[1];
    new_addr_w[2] = new_addr_r[2];
    new_addr_w[3] = new_addr_r[3];
    pix_cntr_w    = pix_cntr_r;
    last_success_w = last_success_r;
    miss_counter_w = miss_counter_r;
    
    valid_w = 0;
    for(integer i = 0; i < 3; i = i + 1) begin
        last_ul_addr_w[i+1] = last_ul_addr_r[i];
        last_ur_addr_w[i+1] = last_ur_addr_r[i];
        last_dl_addr_w[i+1] = last_dl_addr_r[i];
        last_dr_addr_w[i+1] = last_dr_addr_r[i];
    end

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
                    miss_counter_w = 0;
                    last_success_w = 1;
                    last_ul_addr_w[0] = new_addr_r[0];      // new_addr_r[min_index[0][2]];    // new_addr_r[0];
                    last_ur_addr_w[0] = new_addr_r[3];      // new_addr_r[min_index[1][2]];    // new_addr_r[3];
                    last_dl_addr_w[0] = new_addr_r[1];      // new_addr_r[min_index[2][2]];    // new_addr_r[1];
                    last_dr_addr_w[0] = new_addr_r[2];      // new_addr_r[min_index[3][2]];    // new_addr_r[2];
                end
                else begin
                    if (miss_counter_r) begin
                        last_success_w = 0;
                        miss_counter_w = 0;
                        last_ul_addr_w[0] = {10'd0, 10'd0};
                        last_ur_addr_w[0] = {10'd0, 10'd799};
                        last_dl_addr_w[0] = {10'd599, 10'd0};
                        last_dr_addr_w[0] = {10'd599, 10'd799};
                    end
                    else begin
                        last_success_w = 1;
                        miss_counter_w = miss_counter_r + 1;
                        last_ul_addr_w[0] = last_ul_addr_w[1];
                        last_ur_addr_w[0] = last_ur_addr_w[1];
                        last_dl_addr_w[0] = last_dl_addr_w[1];
                        last_dr_addr_w[0] = last_dr_addr_w[1];
                    end
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
        if (!(col_counter_r > new_addr_r[1][9:0])) begin
            new_addr_w[1] = {row_counter_r, col_counter_r};
        end
        if (!(row_counter_r < new_addr_r[2][19:10])) begin
            new_addr_w[2] = {row_counter_r, col_counter_r};
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
        new_addr_r[3]  <= {10'd599, 10'd0};
        new_addr_r[1]  <= {10'd0, 10'd799};
        new_addr_r[2]  <= {10'd0, 10'd0};
        last_success_r <= 0;
        miss_counter_r <= 0;
        valid_r        <= 0;
        for (integer i = 0; i < 4; i = i + 1) begin
            last_ul_addr_r[i] <= {10'd0, 10'd0};
            last_ur_addr_r[i] <= {10'd0, 10'd799};
            last_dl_addr_r[i] <= {10'd599, 10'd0};
            last_dr_addr_r[i] <= {10'd599, 10'd799};
        end
    end
    else begin
        row_counter_r  <= row_counter_w;
        col_counter_r  <= col_counter_w;
        pix_cntr_r     <= pix_cntr_w;
        new_addr_r[0]  <= new_addr_w[0];
        new_addr_r[3]  <= new_addr_w[3];
        new_addr_r[1]  <= new_addr_w[1];
        new_addr_r[2]  <= new_addr_w[2];
        last_success_r <= last_success_w;
        miss_counter_r <= miss_counter_w;
        valid_r        <= valid_w;
        for (integer i = 0; i < 4; i = i + 1) begin
            last_ul_addr_r[i] <= last_ul_addr_w[i];
            last_ur_addr_r[i] <= last_ur_addr_w[i];
            last_dl_addr_r[i] <= last_dl_addr_w[i];
            last_dr_addr_r[i] <= last_dr_addr_w[i];
        end
    end
end

endmodule
