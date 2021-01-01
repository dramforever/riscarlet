module riscarlet
    import  types::*;
(
    input wire  logic       clk,
    input wire  logic       rst,

    input wire  word_t      a,
    output      word_t      b
);

    always_ff @(posedge clk) begin
        if (rst) begin
            b <= 'd0;
        end else begin
            b <= b + a;
        end
    end

endmodule
