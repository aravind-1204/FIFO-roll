module top #(parameter W_WIDTH = 8, parameter MEM_WORDS = 64, parameter R_WORDS = 4) (
    input logic rst_n,
	 input logic clk,

    input logic [W_WIDTH-1:0] w_data,
    input logic w_valid,
    input logic w_last,
    output logic w_ready,

    output logic [R_WORDS*W_WIDTH-1:0] r_data,
    input logic r_ready,
    output logic [R_WORDS-1:0] r_keep,
    output logic r_valid,
    output logic r_last
);

	logic w_clk;
	logic r_clk;
	logic locked;

	clk_pll clk_pll_inst (
		.refclk   (clk),   //  refclk.clk
		.rst      (1'b0),      //   reset.reset
		.outclk_0 (w_clk), // outclk0.clk
		.outclk_1 (r_clk), // outclk1.clk
		.locked   (locked)    //  locked.export
	);
	
	fifo FIFO__ (.*);

endmodule