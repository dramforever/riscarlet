module rscl_core
    import rscl_types::*;
    import rscl_instr::*;
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

    output  logic       d_a_valid,
    input   logic       d_a_ready,
    output  bus_req_t   d_a_req,

    input   logic       d_d_valid,
    output  logic       d_d_ready,
    input   logic       d_d_err,
    input   word_t      d_d_data
);

    rnum_t          read_rs1;
    word_t          read_rs1_val;
    rnum_t          read_rs2;
    word_t          read_rs2_val;

    csr_num_t       read_csr_num;
    csr_num_t       read_csr_val;

    logic           exec_valid;
    exec_instr_t    exec_instr;
    logic           exec_stall;

    logic           jump;
    word_t          jump_pc;

    rscl_fetch rscl_fetch_i (
        .clk,
        .rst,

        .i_a_valid,
        .i_a_ready,
        .i_a_addr,

        .i_d_valid,
        .i_d_ready,
        .i_d_err,
        .i_d_data,

        .fetch_err,
        .fetch_instr,
        .fetch_stall,

        .jump,
        .jump_pc
    );

    rscl_exec rscl_exec_i (
        .clk,
        .rst,

        .fetch_err,
        .fetch_instr,
        .fetch_stall,

        .d_a_valid,
        .d_a_ready,
        .d_a_req,

        .read_rs1,
        .read_rs1_val,
        .read_rs2,
        .read_rs2_val,

        .read_csr_num,
        .read_csr_val,

        .exec_valid,
        .exec_instr,
        .exec_stall
    );

    rscl_rf rscl_rf_i (
        .clk,
        .rst,

        .d_d_valid,
        .d_d_ready,
        .d_d_err,
        .d_d_data,

        .read_rs1,
        .read_rs1_val,
        .read_rs2,
        .read_rs2_val,

        .read_csr_num,
        .read_csr_val,

        .exec_valid,
        .exec_instr,
        .exec_stall,

        .jump,
        .jump_pc
    );

endmodule
