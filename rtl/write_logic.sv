`timescale 1ns/1ps

module write_logic #(parameter W_WIDTH = 8, parameter R_WORDS=4, parameter G_SIZE = 7)(
    input rst_n,

    input w_clk,
    input logic [W_WIDTH-1:0] w_data,
    input logic w_valid,
    input logic w_last,

    input logic [G_SIZE-1:0] r_addr_gray,

    output logic w_ready,
    output logic write,
    output logic [G_SIZE-1:0] w_addr_gray,
    output logic [G_SIZE-2:0] w_addr,
    output logic [W_WIDTH*R_WORDS+R_WORDS:0] write_buffer
);
    parameter buffer_ptr_len = $clog2(R_WORDS);

    // reg [W_WIDTH*R_WORDS+R_WORDS:0] write_buffer;
    logic [buffer_ptr_len-1:0] buffer_ptr;
	 
	 logic [W_WIDTH-1:0] write_array [0:R_WORDS-1];

    logic [G_SIZE-1:0] w_addr_w_ptr;
    assign w_addr = w_addr_w_ptr[G_SIZE-2:0];

    logic [G_SIZE-1:0] r_addr;

    logic [G_SIZE-1:0] w_addr_buf;

    logic [G_SIZE-1:0] w_addr_next;
    assign w_addr_next = w_addr_w_ptr+1;

    // gray_to #(.WIDTH(G_SIZE))g2b_write(w_addr, w_addr);
    bin_to_gray #(.WIDTH(G_SIZE)) b2g_write(w_clk, rst_n, w_addr_w_ptr, w_addr_gray);

    gray_to_bin #(.WIDTH(G_SIZE)) g2b_read(w_clk, rst_n, r_addr_gray, r_addr);

    logic is_full_now;
    logic is_full_next;
    
    assign is_full_now = (w_addr_w_ptr[G_SIZE-2:0]+1 == r_addr[G_SIZE-2:0]) && (w_addr_w_ptr[G_SIZE-1] != r_addr[G_SIZE-1]);
    assign is_full_next = (w_addr_next[G_SIZE-2:0]+1 == r_addr[G_SIZE-2:0]) && (w_addr_next[G_SIZE-1] != r_addr[G_SIZE-1]);

	 logic [R_WORDS-1:0] to_keep;
	 
    always_ff@(posedge w_clk) begin
        if(!rst_n) begin
            w_ready <= 1;
            write_buffer <= '0;
            buffer_ptr <= '0;
            w_addr_w_ptr <= '0;
            w_addr_buf <= '0;
            write <= 0;
				to_keep <= 1<<(R_WORDS-1);
        end else begin
            if(w_valid && w_ready) begin
                // w_ready <= !(is_full_next);
                if((buffer_ptr=='0) || w_last) begin
                    w_ready <= !is_full_next;
                    write <= 1;
                    w_addr_w_ptr <= w_addr_buf;
                    w_addr_buf <= w_addr_buf+1;
                    buffer_ptr <= R_WORDS-1;
						  to_keep <= 1<<(R_WORDS-1);
                end else begin
                    write <= 0;
                    w_addr_w_ptr <= w_addr_w_ptr;
                    w_addr_buf <= w_addr_buf;
                    buffer_ptr <= buffer_ptr-1;
						  to_keep <= to_keep+ (1<<(R_WORDS-int'(buffer_ptr)-2));
						  for(int ptr=0;ptr<R_WORDS;ptr++) begin : loop
								write_buffer[W_WIDTH*ptr +: W_WIDTH] <= write_array[ptr];
						  end
                end
                // write_buffer <= w_dat_shifted | write_buffer;
                // write_buffer <= w_buffer_next;
                write_array[buffer_ptr] <= w_data;
                write_buffer[W_WIDTH*R_WORDS +: R_WORDS] <= to_keep;
                write_buffer[W_WIDTH*R_WORDS+R_WORDS] <= w_last;
            end else begin
                write <= 0;
                w_ready <= !(is_full_now);
            end
        end
    end
endmodule
