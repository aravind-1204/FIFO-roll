`timescale 1ns/1ps

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
    output logic [G_SIZE-2:0] r_addr,
    output logic [R_WORDS-1:0] r_keep,
    output logic [W_WIDTH*R_WORDS-1:0] read_out
);
    // logic [G_SIZE-1:0] r_addr;
    logic [G_SIZE-1:0] w_addr_w_ptr;
    logic [G_SIZE-1:0] r_addr_w_ptr;
    // logic [G_SIZE-1:0] r_addr_next;

    // assign r_addr_next = r_addr_w_ptr+1;
    assign r_addr = r_addr_w_ptr[G_SIZE-2:0];

    bin_to_gray #(.WIDTH(G_SIZE)) b2g_read(r_clk, rst_n, r_addr_w_ptr, r_addr_gray);

    gray_to_bin #(.WIDTH(G_SIZE)) g2b_write(r_clk, rst_n, w_addr_gray, w_addr_w_ptr);

    logic [W_WIDTH*R_WORDS+R_WORDS:0] read_buffer;
    logic [W_WIDTH*R_WORDS+R_WORDS:0] skid_buffer;

    assign read_out = read_buffer[W_WIDTH*R_WORDS-1:0];
    assign r_keep = read_buffer[W_WIDTH*R_WORDS+R_WORDS-1:W_WIDTH*R_WORDS];
    assign r_last = read_buffer[W_WIDTH*R_WORDS+R_WORDS];

    logic is_skid_occ;

    logic is_empty_now;
    // logic is_empty_next;

    logic read_tag_buffer;

    assign is_empty_now = (r_addr_w_ptr == w_addr_w_ptr);
    // assign is_empty_next = (r_addr_next == w_addr_w_ptr);

    // assign read = !is_empty_now && is_skid_occ && (!r_valid || r_ready);
    // logic start_read_next;
    // assign start_read_next = !(is_empty_now) && (!r_valid || r_ready);
    // logic stop_read_next;
    // assign stop_read_next = is_empty_next || !r_ready;

    assign read = !(is_empty_now) && (r_ready || !r_valid);

    always_ff@(posedge r_clk) begin
        if(!rst_n) begin
            // read <= 0;
            is_skid_occ <= 0;
            read_tag_buffer <= 0;
            r_addr_w_ptr <= 0;
            r_valid <= 0;
        end else begin
            read_tag_buffer <= read;
            if(!read) begin
                // read <= start_read_next;
                if(read_tag_buffer) begin
                    is_skid_occ <= 1;
                    skid_buffer <= r_from_mem;
                    r_valid <= (!r_ready)&&(r_valid);
                end else begin
                    r_valid <= (!r_ready)&&(r_valid);
                end
            end else begin
                // read <= !(stop_read_next);
                r_addr_w_ptr <= r_addr_w_ptr+1;
                if(is_skid_occ) begin
                    is_skid_occ <= 0;
                    read_buffer <= skid_buffer;
                    r_valid <= 1;
                end else begin
                    r_valid <= read_tag_buffer&&read;
                    read_buffer <= r_from_mem;
                end
            end
        end
    end

endmodule
