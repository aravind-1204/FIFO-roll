`timescale 1ns/1ps

module bin_to_gray #(parameter WIDTH = 8)(
    input clk,
    input reset_n,
    input  logic [WIDTH-1:0] bin_code,
    output logic [WIDTH-1:0] gray_code
);
    always_ff@(posedge clk) begin
        if(!reset_n)
            gray_code <= 0;
        else
            gray_code <= bin_code ^ (bin_code>>1);
    end
endmodule
