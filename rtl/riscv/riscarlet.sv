module riscarlet
    import  types::*;
(
    input   logic       clk,
    input   logic       rst,

    output  logic       req_valid,
    input   logic       req_ready,
    input   logic       rsp_valid,
    output  logic       rsp_ready,

    output  word_t      addr,
    output  bsel_t      bstb,
    output  logic       we,
    input   word_t      r_data,
    output  word_t      w_data,

    input   logic       ready,
    output  logic       valid,
    output  word_t      instr,

    input   logic       pc_flush,
    input   word_t      pc_new
);

    bus_req_c req ();
    bus_rsp_c rsp ();

    assign addr = req.data.addr;
    assign bstb = req.data.bstb;
    assign we = req.data.we;
    assign w_data = req.data.w_data;

    assign req.ready = req_ready;
    assign req_valid = req.valid;
    assign rsp_ready = rsp.ready;
    assign rsp.valid = rsp_valid;
    assign rsp.data.r_data = r_data;

    pipeline pipe_i ();

    assign valid = pipe_i.valid;
    assign instr = pipe_i.data.instr;
    assign pipe_i.ready = ready;

    stage_fetch stage_fetch_i (
        .clk, .rst,
        .pc_flush, .pc_new,
        .req(req.up),
        .rsp(rsp.dn),
        .dn(pipe_i.dn)
    );
endmodule
