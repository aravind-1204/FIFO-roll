`timescale 1ns/1ps

module synchronizer #(parameter WIDTH = 8)(
    input logic [WIDTH-1:0] in,
    input reset_n,
    input new_clk,

    output logic [WIDTH-1:0] out
);
	 /* Comment the line below when compiling with any other tools.*/
	 (* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS" *)
    logic [WIDTH-1:0] reg1;

    always_ff @(posedge new_clk) begin
        if(!reset_n) begin
            reg1 <= '0;
            out <= '0;
        end else begin
            reg1 <= in;
            out <= reg1;
        end
    end
endmodule
