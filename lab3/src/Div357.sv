module Div357 (
    input  [15:0] i_in,
    input         i_div_3,
    input         i_div_5,
    input         i_div_7,
    output [15:0] o_out
);

logic [19:0] temp;
logic [29:0] out;

assign o_out = out[29-:16];
    
always_comb begin
    case ({i_div_3,i_div_5,i_div_7})
        3'b001: begin // 00_1001_0010_0100
            temp = i_in + (i_in << 3); // 1001
            out  = (temp << 2) + (temp << 8);
        end
        3'b010: begin // 00_1100_1100_1100
            temp = i_in + (i_in << 1); // 11
            out  = (temp << 2) + (temp << 6) + (temp << 10);
        end
        3'b100: begin // 01_0101_0101_0101
            temp = i_in + (i_in << 2); // 101
            out  = ((temp << 2) + (temp << 6)) + ((temp << 10) + (i_in << 12));
        end
        default: begin
            temp = 0;
            out  = 0;
        end 
    endcase    
end

endmodule
