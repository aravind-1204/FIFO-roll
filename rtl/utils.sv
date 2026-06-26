module gray_to_bin #(parameter WIDTH = 8)(
    input  logic [WIDTH-1:0] gray_code,
    output logic [WIDTH-1:0] bin_code
);
    always_comb begin : convert_loop
        for(int i=0;i<WIDTH;i++)
            bin_code[i] = ^(gray_code[WIDTH-1:i]);   
    end

endmodule

module bin_to_gray #(parameter WIDTH = 8)(
    input  logic [WIDTH-1:0] bin_code,
    output logic [WIDTH-1:0] gray_code
);

    assign gray_code = bin_code ^ (bin_code>>1);

endmodule

module gray_code_counter #(parameter WIDTH = 8)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             inc,
    output logic [WIDTH-1:0] gray_code
);
    logic [WIDTH-1:0] bin_code_p;
    logic [WIDTH-1:0] bin_code_n;
    logic [WIDTH-1:0] gray_code_p;
    logic [WIDTH-1:0] gray_code_n;

    gray_to_bin #(.WIDTH(WIDTH)) g2b (
        .gray_code(gray_code_n),
        .bin_code(bin_code_p)
    );

    bin_to_gray #(.WIDTH(WIDTH)) b2g (
        .bin_code(bin_code_n),
        .gray_code(gray_code_p)
    )

    assign bin_code_n = bin_code_p + 1;

    always_ff@(posedge clk) begin
        if(!rst_n) begin
            gray_code_n <= '0;
        end else if (inc) begin
            gray_code_n <= gray_code_p;
        end
    end

    assign gray_code = gray_code_n;

endmodule