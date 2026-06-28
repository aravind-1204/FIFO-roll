module fifo #(parameter W_WIDTH = 8, parameter MEM_WORDS = 64, parameter R_WORDS = 4) (
    input rst_n,

    input w_clk,
    input [W_WIDTH-1:0] w_data,
    input w_valid,
    input w_last,
    output w_ready,

    input r_clk,
    output [R_WORDS*W_WIDTH-1:0] r_data,
    input r_ready,
    output [R_WORDS-1:0] r_keep,
    output r_valid,
    output r_last
);

    parameter G_SIZE = 1 + $clog2(MEM_WORDS);
    parameter R_WIDTH = W_WIDTH*R_WORDS;
    // Write side logic
    logic [G_SIZE-2:0] w_addr;
    logic write;
    logic [G_SIZE-1:0] w_addr_gray_w_clk;
    logic [G_SIZE-1:0] w_addr_gray_r_clk;
    logic [R_WIDTH+R_WORDS:0] write_buffer;

    // Read side logic
    logic [G_SIZE-2:0] r_addr;
    logic read;
    logic [G_SIZE-1:0] r_addr_gray_r_clk;
    logic [G_SIZE-1:0] r_addr_gray_w_clk;
    logic [R_WIDTH+R_WORDS:0] r_from_mem;

    synchronizer #(.WIDTH(G_SIZE)) write_to_read (w_addr_gray_w_clk, rst_n, r_clk, w_addr_gray_r_clk);
    synchronizer #(.WIDTH(G_SIZE)) read_to_write(r_addr_gray_r_clk, rst_n, w_clk, r_addr_gray_w_clk);

    write_logic #(
        .W_WIDTH (W_WIDTH),
        .R_WORDS (R_WORDS),
        .G_SIZE  (G_SIZE)
    ) writer (
        .rst_n        (rst_n),
        .w_clk        (w_clk),
        .w_data       (w_data),
        .w_valid      (w_valid),
        .w_last       (w_last),
        .r_addr_gray  (r_addr_gray_w_clk),
        .w_ready      (w_ready),
        .write        (write),
        .w_addr_gray  (w_addr_gray_w_clk),
        .w_addr       (w_addr),
        .write_buffer (write_buffer)
    );

    read_logic #(
        .W_WIDTH (W_WIDTH),
        .R_WORDS (R_WORDS),
        .G_SIZE  (G_SIZE)
    ) reader (
        .rst_n       (rst_n),
        .r_clk       (r_clk),
        .r_ready     (r_ready),
        .r_from_mem  (r_from_mem),
        .w_addr_gray (w_addr_gray_r_clk),
        .r_valid     (r_valid),
        .r_last      (r_last),
        .read        (read),
        .r_addr_gray (r_addr_gray_r_clk),
        .r_addr      (r_addr),
        .r_keep      (r_keep),
        .read_out    (r_data)
    );

    mem #(.R_WIDTH(R_WIDTH), .ADDR_SIZE(G_SIZE-1)) RAM_block(
        .w_clk(w_clk),
        .w_addr(w_addr[G_SIZE-2:0]),
        .w_dat(write_buffer),
        .write(write),

        .r_clk(r_clk),
        .r_addr(r_addr[G_SIZE-2:0]),
        .r_dat(r_from_mem),
        .read(read)
    );

endmodule
