module riscarlet
    import  types::*;
(
    input   logic       clk,
    input   logic       rst,

    output  logic       stb,
    input   logic       stall,
    input   logic       ack,

    output  word_t      adr,
    output  bsel_t      sel,
    output  logic       we,
    input   word_t      dat_r,
    output  word_t      dat_w,

    input   logic       ready,
    output  logic       valid,
    output  word_t      instr,

    input   logic       pc_flush,
    input   word_t      pc_new
);

    wishbone bus_i ();

    assign stb = bus_i.stb;
    assign adr = bus_i.adr;
    assign sel = bus_i.sel;
    assign we = bus_i.we;
    assign dat_w = bus_i.dat_w;

    assign bus_i.stall = stall;
    assign bus_i.ack = ack;
    assign bus_i.dat_r = dat_r;

    pipeline pipe_i ();

    assign valid = pipe_i.valid;
    assign instr = pipe_i.data.instr;
    assign pipe_i.ready = ready;

    stage_fetch stage_fetch_i (
        .clk, .rst,
        .pc_flush, .pc_new,
        .bus(bus_i.master),
        .dn(pipe_i.dn)
    );
endmodule
