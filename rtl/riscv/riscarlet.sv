module riscarlet
    import  types::*;
(
    input   logic       clk,
    input   logic       rst,

    input   word_t      a,
    output  word_t      b
);

    always_ff @(posedge clk) begin
        if (rst) begin
            b <= 'd0;
        end else begin
            b <= b + a;
        end
    end

endmodule
