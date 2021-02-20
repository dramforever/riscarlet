module stage_fetch
    import types::*;
#(
    parameter   integer     CTR_W = 2
) (
    input   logic       clk,
    input   logic       rst,

    input   logic       pc_flush,
    input   word_t      pc_new,

    wishbone.master     bus,
    pipeline.dn         dn
);

    localparam  integer     FIFO_CAP = 2 ** CTR_W;

    typedef logic [CTR_W - 1 : 0] ctr_t;

    ctr_t       waiting = 'd0;
    ctr_t       discard = 'd0;

    ctr_t       waiting_next;
    ctr_t       discard_next;

    logic       should_discard;
    assign should_discard = (discard > 0);

    always_comb begin
        waiting_next = waiting;
        waiting_next += ctr_t'(bus.stb && ! bus.stall);

        discard_next = discard;

        waiting_next -= ctr_t'(bus.ack);
        discard_next -= ctr_t'((discard > 0) && bus.ack);

        if (pc_flush) begin
            discard_next = waiting_next + ctr_t'(bus.stb && bus.stall);
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            waiting <= 'd0;
            discard <= 'd0;
        end else begin
            waiting <= waiting_next;
            discard <= discard_next;
        end
    end

    // FIFO has one wasted slot
    instr_t     fifo  [FIFO_CAP - 1 : 0];
    ctr_t       fifo_begin = 'd0;
    ctr_t       fifo_end = 'd0;

    logic       fifo_push;
    instr_t     fifo_push_data;
    logic       fifo_pop;

    ctr_t       fifo_count;
    assign      fifo_count = fifo_end - fifo_begin;

    logic       can_issue;
    assign      can_issue = (CTR_W + 2)'(fifo_count) + (CTR_W + 2)'(waiting) < (CTR_W + 2)'(FIFO_CAP - 2);

    word_t      pc = 32'h8000_0000;

    logic       pc_flush_save = '0;
    word_t      pc_new_save;

    logic       pc_flush_now;
    assign      pc_flush_now = pc_flush || pc_flush_save;

    word_t      pc_new_now;
    assign      pc_new_now = pc_flush ? pc_new : pc_new_save;

    always_comb begin
        fifo_pop = '0;
        fifo_push = '0;
        fifo_push_data = '0;

        if (fifo_begin == fifo_end) begin
            // FIFO is empty
            dn.valid = bus.ack && ! should_discard;
            dn.data.instr = bus.dat_r;

            if (bus.ack && ! dn.ready && ! should_discard) begin
                fifo_push = '1;
                fifo_push_data = bus.dat_r;
            end
        end else begin
            // FIFO is not empty
            dn.valid = '1;
            dn.data.instr = fifo[fifo_begin];

            if (bus.ack) begin
                fifo_push = '1;
                fifo_push_data = bus.dat_r;
            end

            if (dn.ready) begin
                fifo_pop = '1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst || pc_flush_now) begin
            fifo_begin <= 'd0;
            fifo_end <= 'd0;
        end else begin
            if (fifo_pop) begin
                fifo_begin <= fifo_begin + 'd1;
            end

            if (fifo_push) begin
                fifo_end <= fifo_end + 'd1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (fifo_push) begin
            fifo[fifo_end] <= fifo_push_data;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'h8000_0000;
        end else begin
            if (! bus.stall) begin
                if (pc_flush_now)
                    pc <= pc_new_now;
                else if (bus.stb)
                    pc <= pc + 'd4;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_flush_save <= '0;
        end else begin
            if (pc_flush)
                pc_flush_save <= '1;
            if (! bus.stall)
                pc_flush_save <= '0;
        end
    end

    always_ff @(posedge clk) begin
        if (pc_flush)
            pc_new_save <= pc_new;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            bus.stb <= '0;
        end else begin
            if (! bus.stall)
                bus.stb <= can_issue && ! should_discard;
        end
    end

    assign  bus.adr = pc;
    assign  bus.we = '0;
    assign  bus.sel = '1;
    assign  bus.dat_w = '0;
endmodule
