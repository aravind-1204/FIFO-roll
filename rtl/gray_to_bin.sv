`timescale 1ns/1ps

module gray_to_bin #(parameter WIDTH = 8)(
    input clk,
    input reset_n,
    input  logic [WIDTH-1:0] gray_code,
    output logic [WIDTH-1:0] bin_code
);
    logic [WIDTH-1:0] next_bin_code;

    genvar i;
    generate 
        for (i = 0; i < WIDTH; i++) begin : loop
            assign next_bin_code[i] = ^(gray_code >> i);
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (!reset_n)
            bin_code <= '0;
        else
            bin_code <= next_bin_code;
    end
endmodule
