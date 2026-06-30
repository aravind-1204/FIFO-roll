`timescale 1ns/1ps

module clk_gen(
    output logic clk,
    input real half_period
);

    initial clk = 0;

    always begin
        if(half_period>0) begin
            // verilator lint_off ZERODLY
            #half_period clk = ~clk; 
            // verilator lint_on ZERODLY
        end else
            #1;
    end

endmodule
