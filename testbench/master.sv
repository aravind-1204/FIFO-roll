`timescale 1ns/1ps

module master #(parameter W_WIDTH=8)(
    input logic rst_n,
    input logic w_clk,

    input logic w_ready,

    output logic [W_WIDTH-1:0] w_data,
    output logic w_valid,
    output logic w_last,
    output logic w_done
);

    task automatic drive_from_file(string filename);
        begin : task_blk
            int fd;
            int status;
            int pkt_len;
            int i;
            int choice;
            logic [W_WIDTH-1:0] temp_data;

            fd=$fopen(filename, "r");
            if(fd==0) begin
                $error("[M] Couldn't open file.\n");
                disable task_blk;
            end
            if(!rst_n) begin
                w_valid = 0;
                w_last = 0;
                w_done = 0;
                @(posedge w_clk);
            end else begin 
                while(!$feof(fd)) begin
                    w_valid = 0;
                    w_done = 0;
                    repeat($urandom_range(5,20)) @(posedge w_clk);
                    status = $fscanf(fd, "%d ", pkt_len);

                    if(status==1) begin
                        $display("[M] Starting new line...\n");
                    end
                    i = 0;
                    while(i<pkt_len) begin
                        choice = $urandom_range(9);
                        if(choice<8) begin
                            i = i+1;
                            status = $fscanf(fd, "%h ", temp_data);

                            w_data = temp_data;
                            w_valid = 1'b1;
                            w_last = (i==pkt_len);

                            do begin
                                @(posedge w_clk);
                            end while(!w_ready);
                        end else begin
                            w_valid = 0;
                            @(posedge w_clk);
                        end
                    end
                end
                $fclose(fd);
                w_valid = 0;
                w_last = 0;
                w_done = 1;
                repeat(25) @(posedge w_clk);
            end
        end
    endtask

endmodule
