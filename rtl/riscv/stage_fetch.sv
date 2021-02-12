module stage_fetch
    import types::*;
#(
    parameter   integer     CTR_W = 2;
) (
    input   logic       clk,
    input   logic       rst,

    input   logic       pc_flush,
    input   word_t      pc_new,

    wishbone.master     bus,
    pipeline.dn         dn
);

    localparam  integer     FIFO_CAP = 2 ** CTR_W - 1;

    typedef logic [CTR_W - 1 : 0] ctr_t;

    ctr_t       waiting = 'd0;
    ctr_t       discard = 'd0;

    // FIFO has one wasted slot
    instr_t     fifo  [FIFO_CAP : 0];
    ctr_t       fifo_begin = 'd0;
    ctr_t       fifo_end = 'd0;

    logic       can_issue;
    assign      can_issue =
        (CTR_W + 1)'(
            CTR_W'(fifo_end - fifo_begin) + waiting
        ) < CTR_W'(FIFO_CAP);

    always_ff @(posedge clk) begin
        if (rst) begin
            waiting <= 'd0;
            discard <= 'd0;
        end else begin
            waiting += bus.ack;
        end
    end

endmodule
