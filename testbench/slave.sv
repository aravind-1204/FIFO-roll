`timescale 1ns/1ps

module slave#(parameter W_WIDTH=8, parameter R_WORDS=4)(
    input logic rst_n,
    input logic r_clk,

    input logic r_done,

    input logic [R_WORDS*W_WIDTH-1:0] r_data,
    input logic [R_WORDS-1:0] r_keep,
    input logic r_valid,
    input logic r_last,

    output logic r_ready
);

    task automatic read_to_file(string filename);
        begin : task_blk
            int fd;
            int choice;
            int i;
            logic [W_WIDTH*R_WORDS-1:0] temp_data;

            fd = $fopen(filename, "w");
            if(fd==0) begin
                $error("[S] Couldn't open file.\n");
                disable task_blk;
            end
            if(!rst_n) begin
                r_ready = 0;
                @(posedge r_clk);
            end else begin
                while(!r_done) begin
                    choice = $urandom_range(9);
                    if(choice<8) begin
                        r_ready = 1;
                        do begin
                            @(posedge r_clk);
                        end while(!r_valid);
                        temp_data = r_data;
                        for(i=0;i<R_WORDS;i++) begin
                            if(r_keep[i]==0) begin
                                temp_data[i*W_WIDTH +: W_WIDTH] = '0;
                            end
                        end
                        $fwrite(fd, "%h", temp_data);
                        if(r_last)
                            $fwrite(fd, "\n");
                    end else begin
                        r_ready = 0;
                        @(posedge r_clk);
                    end
                end
                $fclose(fd);
                r_ready = 0;
                repeat(25) @(posedge r_clk);
            end
        end
        $finish;
    endtask
endmodule
