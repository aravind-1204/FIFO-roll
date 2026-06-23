`include "utils.sv"

module write_logic #(parameter W_WIDTH = 8, parameter R_WORDS=4, parameter G_SIZE = 7)(
    input async_rst_n,

    input w_clk,
    input logic [W_WIDTH-1:0] w_data,
    input logic w_valid,
    input logic w_last,

    input logic r_addr,

    output logic w_ready,
    output logic write,
    output logic [G_SIZE-1:0] w_addr,
    output logic [G_SIZE-1:0] w_addr_bin;
    output [W_WIDTH*R_WORDS+R_WORDS:0] write_buffer;
);
    parameter buffer_ptr_len = $clog2(R_WORDS);

    // reg [W_WIDTH*R_WORDS+R_WORDS:0] write_buffer;
    logic [buffer_prt_len-1:0] buffer_ptr;

    // logic [G_SIZE-1:0] w_addr_bin;
    logic [G_SIZE-1:0] r_addr_bin;

    logic [G_SIZE-1:0] w_addr_bin_buf;

    logic [G_SIZE-1:0] w_addr_bin_next;
    assign w_addr_bin_next = w_addr_bin+1;

    // gray_to_bin #(.WIDTH(G_SIZE))g2b_write(w_addr, w_addr_bin);
    bin_to_gray #(.WIDTH(G_SIZE)) b2g_write(w_addr_bin, w_addr);

    gray_to_bin #(.WIDTH(G_SIZE)) g2b_read(r_addr, r_addr_bin);

    logic is_full_now;
    logic is_full_next;
    
    assign is_full_now = (w_addr_bin[G_SIZE-2:0] == r_addr_bin[G_SIZE02:0]) && (w_addr_bin[G_SIZE-1] != r_addr_bin[G_SIZE-1]);
    assign is_full_next = (w_addr_bin_next[G_SIZE-2:0] == r_addr_bin[G_SIZE02:0]) && (w_addr_bin_next[G_SIZE-1] != r_addr_bin[G_SIZE-1]);

    always_ff@(posedge w_clk or negedge async_rst_n) begin
        if(!async_rst_n) begin
            w_ready <= 1;
            write_buffer <= '0;
            buffer_ptr <= '0;
            w_addr_bin <= '0;
            w_addr_bin_buf <= '0;
            write <= 0;
        end else begin
            if(w_valid && w_ready) begin
                w_ready <= !(is_full_next);
                if((&buffer_ptr) || w_last) begin
                    write <= 1;
                    w_addr_bin <= w_addr_bin_buf;
                    w_addr_bin_buf <= w_addr_bin_buf+1;
                end else begin
                    write <= 0;
                    w_addr_bin <= w_addr_bin;
                    w_addr_bin_buf <= w_addr_bin_buf;
                end

                write_buffer[W_WIDTH*(buffer_ptr+1)-1:W_WIDTH*buffer_ptr] <= w_data;
                write_buffer[W_WIDTH*R_WORDS+buffer_ptr] <= 1;
                write_buffer[W_WIDTH*R_WORDS] <= w_last;
                buffer_ptr <= buffer_ptr+1;
            end else begin
                write <= 0;
                w_ready <= !(is_full_now);
            end
        end
    end
endmodule

module read_logic #(parameter W_WIDTH=8, parameter R_WORDS=4, parameter G_SIZE=7)(
    input async_rst_n,

    input r_clk,
    input logic r_ready,
    
    input logic [G_SIZE-1:0] w_addr,

    output logic r_valid,
    output logic r_last,
    output logic read,
    output logic [G_SIZE-1:0] r_addr,
    output logic [G_SIZE-1:0] r_addr_bin,
    output logic [R_WORDS-1:0] r_keep,
    output logic [W_WIDTH*R_WORDS-1:0] r_data
);

    // logic [G_SIZE-1:0] r_addr_bin;
    logic [G_SIZE-1:0] w_addr_bin;

    logic [G_SIZE-1:0] r_addr_bin_buf;

    logic [G_SIZE-1:0] r_addr_bin_next;
    assign r_addr_bin_next = r_addr_bin+1;

    bin_to_gray #(.WIDTH(G_SIZE)) b2g_read(r_addr_bin, r_addr);

    gray_to_bin #(.WIDTH(G_SIZE)) g2b_write(w_addr, w_addr_bin);

    logic [W_WIDTH*R_WORDS+R_WORDS:0] read_buffer;
    logic [W_WIDTH*R_WORDS+R_WORDS:0] skid_buffer;

    logic is_buffer_occ;
    logic is_skid_occ;

    logic is_empty_now;
    logic is_empty_next;

    assign is_empty_now = (r_addr_bin == w_addr_bin);
    assign is_empty_next = (r_addr_bin_next == w_addr_bin);

    always_ff @(posedge r_clk or negedge async_rst_n) begin
        if(!async_rst_n) begin
            is_buffer_occ <= 0;
            is_skid_occ <= 0;

            is_empty_next <= 1;
            is_empty_now <= 1;

            r_valid <= 0;
            r_addr_bin <= '0;
            r_addr_bin_buf <= '0;
            read <= 0;
        end else begin
            if(is_empty_now) begin
                read <= 0;
                r_valid <= 0;
            end else if(!is_buffer_occ) begin
                if(!read)
            end
        end
    end
endmodule

module write_to_read();

endmodule

module read_to_write();

endmodule

module mem #(parameter R_WIDTH = 32, paramete R_WORDS = 4, parameter G_SIZE = 7)(
    input w_clk,
    input [G_SIZE-1:0] w_addr,
    input [R_WIDTH+R_WORDS:0] w_dat,
    input write,

    input r_clk,
    input [G_SIZE-1:0] r_addr,
    output [R_WIDTH+R_WORDS:0] r_dat,
    input read
);
    parameter MEM_WORDS = 1<<(G_SIZE-1);

    reg [R_WIDTH-1:0] RAM [0:MEM_WORDS-1];
    reg [R_WIDTH:0] r_dat_reg;

    always_ff@(posedge w_clk) begin
        if(write) begin
            RAM[w_addr] <= w_dat;
        end
    end

    always_ff @(posedge r_clk) begin 
        if(read) begin
            r_dat_reg <= RAM[r_addr]
        end
    end

    assign r_dat = r_dat_reg;

endmodule

module fifo #(parameter W_WIDTH = 8, parameter MEM_WORDS = 64, parameter R_WORDS = 4) (
    input async_rst_n,

    input w_clk,
    input [W_WIDTH-1:0] w_data,
    input w_valid,
    input w_last,
    output w_ready,

    input r_clk,
    output [R_WORDS*W_WIDTH-1:0] r_data,
    input r_ready,
    output [R_WORDS-1:0] r_keep,
    output r_valid
);



endmodule
