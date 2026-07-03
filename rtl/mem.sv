`timescale 1ns/1ps

module mem #(parameter R_WIDTH = 32, parameter R_WORDS = 4, parameter ADDR_SIZE = 6)(
    input w_clk,
    input [ADDR_SIZE-1:0] w_addr,
    input [R_WIDTH+R_WORDS:0] w_dat,
    input write,

    input r_clk,
    input [ADDR_SIZE-1:0] r_addr,
    output [R_WIDTH+R_WORDS:0] r_dat,
    input read
);
    parameter MEM_WORDS = 1<<(ADDR_SIZE);

    logic [R_WIDTH+R_WORDS:0] RAM [0:MEM_WORDS-1];
    logic [R_WIDTH+R_WORDS:0] r_dat_reg;

    always_ff@(posedge w_clk) begin
        if(write) begin
            RAM[w_addr] <= w_dat;
        end
    end


    always_ff @(posedge r_clk) begin 
        if(read) begin
            r_dat_reg <= RAM[r_addr];
        end
    end

    assign r_dat = r_dat_reg;
endmodule
