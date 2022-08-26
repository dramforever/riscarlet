module rscl_rf
    import rscl_types::*;
    import rscl_instr::*;
(
    input   logic           clk,
    input   logic           rst,

    input   logic           d_d_valid,
    output  logic           d_d_ready,
    input   logic           d_d_err,
    input   word_t          d_d_data,

    input   rnum_t          read_rs1,
    output  word_t          read_rs1_val,
    input   rnum_t          read_rs2,
    output  word_t          read_rs2_val,

    input   csr_num_t       read_csr_num,
    output  csr_num_t       read_csr_val,

    input   logic           exec_valid,
    input   exec_instr_t    exec_instr,
    output  logic           exec_stall,

    output  logic           jump,
    output  word_t          jump_pc
);

    // TODO

endmodule
