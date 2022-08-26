module rscl_fetch
    import rscl_types::*;
    import rscl_bus::*;
(
    input   logic       clk,
    input   logic       rst,

    output  logic       i_a_valid,
    input   logic       i_a_ready,
    output  word_t      i_a_addr,

    input   logic       i_d_valid,
    output  logic       i_d_ready,
    input   logic       i_d_err,
    input   word_t      i_d_data,

    output  logic       fetch_err,
    output  instr_t     fetch_instr,
    input   logic       fetch_stall,

    input   logic       jump,
    input   word_t      jump_pc
);

    // TODO

endmodule
