`include "utils.sv"

module write_logic #(parameter W_WIDTH = 8, parameter R_WORDS=4, parameter G_SIZE = 7)(
    input rst_n,

    input w_clk,
    input logic [W_WIDTH-1:0] w_data,
    input logic w_valid,
    input logic w_last,

    input logic r_addr_gray,

    output logic w_ready,
    output logic write,
    output logic [G_SIZE-1:0] w_addr_gray,
    output logic [G_SIZE-1:0] w_addr;
    output [W_WIDTH*R_WORDS+R_WORDS:0] write_buffer;
);
    parameter buffer_ptr_len = $clog2(R_WORDS);

    // reg [W_WIDTH*R_WORDS+R_WORDS:0] write_buffer;
    logic [buffer_prt_len-1:0] buffer_ptr;

    // logic [G_SIZE-1:0] w_addr;
    logic [G_SIZE-1:0] r_addr;

    logic [G_SIZE-1:0] w_addr_buf;

    logic [G_SIZE-1:0] w_addr_next;
    assign w_addr_next = w_addr+1;

    // gray_to #(.WIDTH(G_SIZE))g2b_write(w_addr, w_addr);
    bin_to_gray #(.WIDTH(G_SIZE)) b2g_write(w_addr, w_addr_gray);

    gray_to_bin #(.WIDTH(G_SIZE)) g2b_read(r_addr_gray, r_addr);

    logic is_full_now;
    logic is_full_next;
    
    assign is_full_now = (w_addr[G_SIZE-2:0] == r_addr[G_SIZE-2:0]) && (w_addr[G_SIZE-1] != r_addr[G_SIZE-1]);
    assign is_full_next = (w_addr_next[G_SIZE-2:0] == r_addr[G_SIZE-2:0]) && (w_addr_next[G_SIZE-1] != r_addr[G_SIZE-1]);

    always_ff@(posedge w_clk) begin
        if(!rst_n) begin
            w_ready <= 1;
            write_buffer <= '0;
            buffer_ptr <= '0;
            w_addr <= '0;
            w_addr_buf <= '0;
            write <= 0;
        end else begin
            if(w_valid && w_ready) begin
                // w_ready <= !(is_full_next);
                if((&buffer_ptr) || w_last) begin
                    w_ready <= !is_full_next;
                    write <= 1;
                    w_addr <= w_addr_buf;
                    w_addr_buf <= w_addr_buf+1;
                end else begin
                    write <= 0;
                    w_addr <= w_addr;
                    w_addr_buf <= w_addr_buf;
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
    input rst_n,

    input r_clk,
    input logic r_ready,
    input logic [W_WIDTH*R_WORDS+R_WORDS:0] r_from_mem,

    input logic [G_SIZE-1:0] w_addr_gray,

    output logic r_valid,
    output logic r_last,
    output logic read,
    output logic [G_SIZE-1:0] r_addr_gray,
    output logic [G_SIZE-1:0] r_addr,
    output logic [R_WORDS-1:0] r_keep,
    output logic [W_WIDTH*R_WORDS-1:0] read_out
);

    // logic [G_SIZE-1:0] r_addr;
    logic [G_SIZE-1:0] w_addr;

    logic [G_SIZE-1:0] r_addr_buf;

    logic [G_SIZE-1:0] r_addr_next;
    assign r_addr_next = r_addr+1;

    bin_to_gray #(.WIDTH(G_SIZE)) b2g_read(r_addr, r_addr_gray);

    gray_to_bin #(.WIDTH(G_SIZE)) g2b_write(w_addr_gray, w_addr);

    logic [W_WIDTH*R_WORDS+R_WORDS:0] read_buffer;
    logic [W_WIDTH*R_WORDS+R_WORDS:0] skid_buffer;

    assign read_out = read_buffer[W_WIDTH*R_WORDS-1:0];
    assign r_keep = read_buffer[W_WIDTH*R_WORDS+R_WORDS-1:W_WIDTH*R_WORDS];
    assign r_last = read_buffer[W_WIDTH*R_WORDS+R_WORDS];

    logic is_buffer_occ;
    logic is_skid_occ;

    logic is_empty_now;
    logic is_empty_next;

    logic read_tag_buffer;

    assign is_empty_now = (r_addr == w_addr);
    assign is_empty_next = (r_addr_next == w_addr);

    // assign read = !is_empty_now && is_skid_occ && (!r_valid || r_ready);

    always_ff@(posedge r_clk) begin
        if(!rst_n) begin
            read <= 0;
            is_buffer_occ <= 0;
            is_skid_occ <= 0;
            read_tag_buffer <= 0;
            r_addr <= 0;
            r_valid <= 0;
        end else begin
            read_tag_buffer <= read;
            if(!read) begin
                read <= !is_empty_now && (!r_valid || r_ready);
                if(read_tag_buffer) begin
                    is_skid_occ <= 0;
                    skid_buffer <= r_from_mem;
                end else begin
                    r_valid <= !r_ready;
                end
            end else begin
                read <= !is_empty_next || !r_ready;
                r_addr <= r_addr+1;
                if(is_skid_occ) begin
                    is_skid_occ <= 0;
                    read_buffer <= skid_buffer;
                    r_valid <= 1;
                end else begin
                    r_valid <= read_tag_buffer || !r_ready;
                    read_buffer <= r_from_mem;
                end
            end
        end
    end

endmodule

module synchronizer #(parameter WIDTH = 8)(
    input logic [WIDTH-1:0] in,
    input reset_n,
    input new_clk,

    output logic [WIDTH-1:0] out
);

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

module mem #(parameter R_WIDTH = 32, paramete R_WORDS = 4, parameter G_SIZE = 7)(
    input w_clk,
    input [G_SIZE-1:0] w_addr,
    input [R_WIDTH*R_WORDS+R_WORDS:0] w_dat,
    input write,

    input r_clk,
    input [G_SIZE-1:0] r_addr,
    output [R_WIDTH*R_WORDS+R_WORDS:0] r_dat,
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

    parameter G_SIZE = 1 + $clog2(MEM_WORDS);

    // Write side logic
    logic [G_SIZE-1:0] w_addr;
    logic [G_SIZE-1:0] w_addr_gray;

    // Read side logic

endmodule
