module Image_Loader (
    input         i_clk,
    output [15:0] data,
    output        valid,
    input         avm_clk,
    input         avm_rst_n,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

localparam S_CHECK = 1'b0;
localparam S_TRANS = 1'b1;

logic        state_r, state_w;
logic        receive_num_r, receive_num_w;
logic  [4:0] avm_address_r, avm_address_w;
logic        avm_read_r, avm_read_w, avm_write_r, avm_write_w;
logic [15:0] data_r, data_w;
logic        valid_r, valid_w;

assign avm_address   = avm_address_r;
assign avm_read      = avm_read_r;
assign avm_write     = avm_write_r;
assign data          = data_r;
assign valid         = valid_r;

always_comb begin : FSM
    state_w = state_r;
    if (avm_clk == 1) begin
        case (state_r)
            S_CHECK: begin
                if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                    state_w = S_TRANS;
                end
            end
            S_TRANS: begin
                if(!avm_waitrequest) begin
                    state_w = S_CHECK;
                end
            end
            default: begin
                state_w = S_CHECK;
            end
        endcase
    end
end

always_comb begin
    receive_num_w   = receive_num_r;
    avm_address_w   = avm_address_r;
    avm_read_w      = avm_read_r;
    avm_write_w     = avm_write_r;
    data_w          = data_r;
    valid_w         = 0;

    if (avm_clk == 1) begin
        case (state_r)
            S_CHECK: begin
                avm_read_w = 1;
                avm_write_w = 0;
                avm_address_w = STATUS_BASE;
                valid_w = 0;
                
                if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                    avm_read_w = 0;
                end
            end
            S_TRANS: begin
                avm_read_w = 1;
                avm_write_w = 0;
                avm_address_w = RX_BASE;
                
                if(!avm_waitrequest) begin
                    if(receive_num_r == 0) begin
                        data_w[7:0] = avm_readdata[7:0];
                    end
                    else begin
                        data_w[15:8] = avm_readdata[7:0];
                        valid_w = 1;
                    end
                    receive_num_w = receive_num_r + 1;
                    avm_read_w = 0;
                end
            end
            default: begin
                receive_num_w   = receive_num_r;
                avm_address_w   = avm_address_r;
                avm_read_w      = avm_read_r;
                avm_write_w     = avm_write_r;
                data_w          = data_r;
                valid_w         = 0;
            end
        endcase
    end
end

always_ff @(posedge i_clk or negedge avm_rst_n) begin
    if (!avm_rst_n) begin
        state_r         <= S_CHECK;
        receive_num_r   <= 0;
        data_r          <= 0;
        valid_r         <= 0;
        avm_address_r   <= STATUS_BASE;
        avm_read_r      <= 0;
        avm_write_r     <= 0;
    end
    else begin
        state_r         <= state_w;
        receive_num_r   <= receive_num_w;
        data_r          <= data_w;
        valid_r         <= valid_w;
        avm_address_r   <= avm_address_w;
        avm_read_r      <= avm_read_w;
        avm_write_r     <= avm_write_w;
    end
end
endmodule
