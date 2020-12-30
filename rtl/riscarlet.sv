module riscarlet (
    rst, clk,
    a, b
);
    import  types::*;

    input wire  logic       rst;
    input wire  logic       clk;

    input wire  word_t      a;
    output      word_t      b;

    always @(posedge clk) begin
        if (rst) begin
            b <= 'd0;
        end else begin
            b <= b + a;
        end
    end

endmodule
