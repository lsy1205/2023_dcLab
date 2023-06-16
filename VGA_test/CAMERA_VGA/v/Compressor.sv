module Compressor (
    input         i_clk,
    input         i_rst_n,
    input         i_gen_valid,
    input  [23:0] i_data,
    output        o_valid,
    output [15:0] o_data
);


integer i;
logic [ 9:0] row_counter_r, row_counter_w;
logic [ 9:0] col_counter_r, col_counter_w;
logic [23:0] decomp_new_r, decomp_new_w;
logic [23:0] decomp_r[0:798], decomp_w[0:798];
logic [ 8:0] ref_R, ref_G, ref_B;
logic [ 8:0] diff_R, diff_G, diff_B;

assign o_valid = i_gen_valid;
assign ref_R  = ( (col_counter_r == 10'b0) ? 8'h7f : decomp_new_r[23:16] ) + ( (row_counter_r == 10'b0) ? 8'h7f : decomp_r[798][23:16] );
assign ref_G  = ( (col_counter_r == 10'b0) ? 8'h7f : decomp_new_r[15: 8] ) + ( (row_counter_r == 10'b0) ? 8'h7f : decomp_r[798][15: 8] );
assign ref_B  = ( (col_counter_r == 10'b0) ? 8'h7f : decomp_new_r[ 7: 0] ) + ( (row_counter_r == 10'b0) ? 8'h7f : decomp_r[798][ 7: 0] );
assign diff_R = i_data[23:16] - ref_R[8:1];
assign diff_G = i_data[15: 8] - ref_G[8:1];
assign diff_B = i_data[ 7: 0] - ref_B[8:1];

assign o_data[15:11] = (diff_R[8:7] == 2'b01) ? 5'h0f :
                       (diff_R[8:7] == 2'b10) ? 5'h10 :
                        diff_R[7:3];
assign o_data[10: 5] = (diff_G[8:7] == 2'b01) ? 6'h1f :
                       (diff_G[8:7] == 2'b10) ? 6'h20 :
                        diff_G[7:2];
assign o_data[ 4: 0] = (diff_B[8:7] == 2'b01) ? 5'h0f :
                       (diff_B[8:7] == 2'b10) ? 5'h10 :
                        diff_B[7:3];

// assign o_data[15:11] = diff_R[8:5];
// assign o_data[10: 5] = diff_G[8:4];
// assign o_data[ 4: 0] = diff_B[8:5];


always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    decomp_new_w  = decomp_new_r;
    for (i = 0; i < 799; i=i+1) begin
        decomp_w[i] = decomp_r[i];
    end

    if (i_gen_valid) begin
        decomp_w[0] = decomp_new_r;
        for (i = 1; i < 799; i=i+1) begin
            decomp_w[i] = decomp_r[i-1];
        end

        decomp_new_w[23:16] = ref_R[8:1] + (o_data[15:11] << 3);
        decomp_new_w[15: 8] = ref_G[8:1] + (o_data[10: 5] << 2);
        decomp_new_w[ 7: 0] = ref_B[8:1] + (o_data[ 4: 0] << 3);
        // decomp_new_w[23:16] = $signed({1'b0, ref_R[8:1]}) + ($signed(o_data[15:11]) << 5);
        // decomp_new_w[15: 8] = $signed({1'b0, ref_G[8:1]}) + ($signed(o_data[10: 5]) << 4);
        // decomp_new_w[ 7: 0] = $signed({1'b0, ref_B[8:1]}) + ($signed(o_data[ 4: 0]) << 5);

        if (col_counter_r == 799) begin
            col_counter_w = 10'b0;
            if (row_counter_r == 599) begin
                row_counter_w = 10'b0;
            end
            else begin
                row_counter_w = row_counter_r + 1;
            end
        end
        else begin
            col_counter_w = col_counter_r + 1;
        end
    end
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r <= 10'b0;
        col_counter_r <= 10'b0;
        decomp_new_r  <= 24'b0;
        for (i = 0; i < 799; i=i+1) begin
            decomp_r[i] <= 24'b0;   // {8'h7f, 8'h7f, 8'h7f};
        end
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        decomp_new_r  <= decomp_new_w;
        for (i = 0; i < 799; i=i+1) begin
            decomp_r[i] <= decomp_w[i];
        end
    end
end

endmodule


module Decompressor (
    input         i_clk,
    input         i_rst_n,
    input         i_req,
    input  [15:0] i_data,
    output        o_req,
    output [23:0] o_data
);


integer i;
logic [ 9:0] row_counter_r, row_counter_w;
logic [ 9:0] col_counter_r, col_counter_w;
logic [23:0] decomp_new_r, decomp_new_w;
logic [23:0] decomp_r[0:798], decomp_w[0:798];
logic [ 8:0] ref_R, ref_G, ref_B;

logic req_r, req_w;

assign o_req = i_req;
assign ref_R  = ( (col_counter_r == 10'b0) ? 8'h7f : decomp_new_r[23:16] ) + ( (row_counter_r == 10'b0) ? 8'h7f : decomp_r[798][23:16] );
assign ref_G  = ( (col_counter_r == 10'b0) ? 8'h7f : decomp_new_r[15: 8] ) + ( (row_counter_r == 10'b0) ? 8'h7f : decomp_r[798][15: 8] );
assign ref_B  = ( (col_counter_r == 10'b0) ? 8'h7f : decomp_new_r[ 7: 0] ) + ( (row_counter_r == 10'b0) ? 8'h7f : decomp_r[798][ 7: 0] );

assign o_data = decomp_new_w;


always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    decomp_new_w  = decomp_new_r;
    req_w         = i_req;
    for (i = 0; i < 799; i=i+1) begin
        decomp_w[i] = decomp_r[i];
    end

    if (req_r) begin
        decomp_w[0] = decomp_new_r;
        for (i = 1; i < 799; i=i+1) begin
            decomp_w[i] = decomp_r[i-1];
        end

        decomp_new_w[23:16] = ref_R[8:1] + (i_data[15:11] << 3);
        decomp_new_w[15: 8] = ref_G[8:1] + (i_data[10: 5] << 2);
        decomp_new_w[ 7: 0] = ref_B[8:1] + (i_data[ 4: 0] << 3);
        // decomp_new_w[23:16] = $signed({1'b0, ref_R[8:1]}) + ($signed(i_data[15:11]) << 5);
        // decomp_new_w[15: 8] = $signed({1'b0, ref_G[8:1]}) + ($signed(i_data[10: 5]) << 4);
        // decomp_new_w[ 7: 0] = $signed({1'b0, ref_B[8:1]}) + ($signed(i_data[ 4: 0]) << 5);

        if (col_counter_r == 799) begin
            col_counter_w = 10'b0;
            if (row_counter_r == 599) begin
                row_counter_w = 10'b0;
            end
            else begin
                row_counter_w = row_counter_r + 1;
            end
        end
        else begin
            col_counter_w = col_counter_r + 1;
        end
    end
end


always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r <= 10'b0;
        col_counter_r <= 10'b0;
        decomp_new_r  <= 24'b0;
        req_r         <= 1'b0;
        for (i = 0; i < 799; i=i+1) begin
            decomp_r[i] <= 24'b0;   // {8'h7f, 8'h7f, 8'h7f};
        end
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        decomp_new_r  <= decomp_new_w;
        req_r         <= req_w;
        for (i = 0; i < 799; i=i+1) begin
            decomp_r[i] <= decomp_w[i];
        end
    end
end

endmodule
