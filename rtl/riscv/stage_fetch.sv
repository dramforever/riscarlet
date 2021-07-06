module stage_fetch
    import types::*;
#(
    parameter   integer     CTR_W = 3
) (
    input   logic       clk,
    input   logic       rst,

    input   logic       pc_flush,
    input   word_t      pc_new,

    bus_req_c.up       req,
    bus_rsp_c.dn       rsp,
    pipeline.dn         dn
);

    typedef logic [CTR_W - 1 : 0] ctr_t;

    ctr_t   pending;
    ctr_t   to_flush;

    ctr_t   pending_next;
    ctr_t   to_flush_next;

    always_comb begin
        pending_next = pending;

        if (req.valid && req.ready) pending_next += 'd1;
        if (rsp.valid && rsp.ready) pending_next -= 'd1;
    end

    always_comb begin
        to_flush_next = to_flush;
        if (to_flush_next > 0 && rsp.valid && rsp.ready)
            to_flush_next -= 'd1;

        if (pc_flush)
            to_flush_next = pending_next;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pending <= '0;
            to_flush <= '0;
        end else begin
            pending <= pending_next;
            to_flush <= to_flush_next;
        end
    end

    logic   can_fire;
    assign can_fire = pending < 3;

    word_t  pc;
    word_t  pc_next;

    logic  pc_flush_wait;
    word_t  pc_new_wait;
    logic  pc_flush_wait_next;
    word_t  pc_new_wait_next;

    always_comb begin
        pc_next = pc;
        pc_flush_wait_next = pc_flush_wait;
        pc_new_wait_next = pc_new_wait;

        if (pc_flush) begin
            pc_flush_wait_next = '1;
            pc_new_wait_next = pc_new;
        end

        if (req.valid && req.ready) begin
            pc_next = pc_next + 'd4;
        end

        if (! req.valid || req.ready) begin
            if (pc_flush_wait_next) begin
                pc_next = pc_new_wait_next;
            end
            pc_flush_wait_next = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= '0;
            pc_flush_wait <= '0;
            pc_new_wait <= '0;
        end else begin
            pc <= pc_next;
            pc_flush_wait <= pc_flush_wait_next;
            pc_new_wait <= pc_new_wait_next;
        end
    end

    assign req.data = '{
        we: '0,
        addr: pc,
        w_data: 'x,
        bstb: '1
    };

    logic not_in_reset;

    always_ff @(posedge clk) begin
        if (rst) begin
            not_in_reset <= '0;
        end else begin
            not_in_reset <= '1;
        end
    end

    assign req.valid = not_in_reset && can_fire;

    assign rsp.ready = (dn.ready || (to_flush > '0));
    assign dn.data.instr = rsp.data;
    assign dn.valid = rsp.valid && to_flush == '0;
endmodule
