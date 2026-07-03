`timescale 1ns/1ps

module tb_fifo;
    parameter W_WIDTH = 8;
    parameter R_WORDS = 4;
    parameter MEM_WORDS = 16;

    logic rst_n;

    logic w_clk;
    real w_half_period;
    logic [W_WIDTH-1:0] w_data;
    logic w_valid;
    logic w_last;
    logic w_ready;

    logic r_clk;
    real r_half_period;
    logic [R_WORDS*W_WIDTH-1:0] r_data;
    logic r_ready;
    logic [R_WORDS-1:0] r_keep;
    logic r_valid;
    logic r_last;

    logic w_done;
    logic r_done;
    assign r_done = w_done;

    string dump_loc;
/* 
    initial begin
        if(!$value$plusargs("DUMPFILE=%s", dump_loc))
            dump_loc = "dump.vcd";

        $dumpfile(dump_loc);
        $dumpvars(0, tb_fifo);

        for(int i=0;i<MEM_WORDS;i++) begin
            $dumpvars(0, tb_fifo.uut.RAM_block.RAM[i]);
        end
    end */

    clk_gen w_clk_gen(.clk(w_clk), .half_period(w_half_period));
    clk_gen r_clk_gen(.clk(r_clk), .half_period(r_half_period));

    initial begin
        if ($test$plusargs("FAST_WRITE")) begin
            w_half_period = 2.5; // 119.05MHz
            r_half_period = 40.0; //33MHz
        end else if($test$plusargs("FAST_READ")) begin
            w_half_period = 40.0; // 25MHz
            r_half_period = 2.5; // 150.15MHz
        end else begin
            w_half_period = 10.0; // 50 MHz
            r_half_period = 10.0; // 50MHz
        end
    end

    fifo #(.W_WIDTH(W_WIDTH), .R_WORDS(R_WORDS), .MEM_WORDS(MEM_WORDS)) uut(.*);
    master #(.W_WIDTH(W_WIDTH)) M(.*);
    slave #(.W_WIDTH(W_WIDTH), .R_WORDS(R_WORDS)) S(.*);

    // initial M.drive_from_file("./testfiles/data.txt");
    // initial S.read_to_file("./testfiles/verify.txt");
	
	initial M.drive_from_file("..\\..\\testfiles\\data.txt");
	initial S.read_to_file("..\\..\\testfiles\\verify.txt");
	
    initial begin
        rst_n = 0;
        #50 rst_n = 1;
    end

endmodule
