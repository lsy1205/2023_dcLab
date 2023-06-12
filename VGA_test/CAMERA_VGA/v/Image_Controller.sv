module Image_Controller (
    input  i_clk,
    input  i_rst_n,
    input  wen,
    input  [23:0] i_data,
    input  [13:0] i_address,
    output [23:0] o_data
);

logic [13:0] addr, addr_counter_r, addr_counter_w;
assign addr = wen ? addr_counter_r : i_address; 

RAM_image ram_imgae (
    aclr(~i_rst_n),
    address(addr),
    clock(i_clk),
    data(i_data),
    wren(wen),
    q(o_data)
);

always_comb begin
    addr_counter_w = addr_counter_r;
    if (wen) begin
        addr_counter_w = addr_counter_r + 1;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        addr_counter_r <= 0;
    end
    else begin
        addr_counter_r <= addr_counter_w;  
    end
end

endmodule