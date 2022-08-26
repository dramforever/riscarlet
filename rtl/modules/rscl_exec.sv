module rscl_exec
    import rscl_types::*;
    import rscl_instr::*;
    import rscl_bus::*;
(
    input   logic           clk,
    input   logic           rst,

    input   logic           fetch_err,
    input   instr_t         fetch_instr,
    output  logic           fetch_stall,

    output  logic           d_a_valid,
    input   logic           d_a_ready,
    output  bus_req_t       d_a_req,

    output  rnum_t          read_rs1,
    input   word_t          read_rs1_val,
    output  rnum_t          read_rs2,
    input   word_t          read_rs2_val,

    output  csr_num_t       read_csr_num,
    input   csr_num_t       read_csr_val,

    output  logic           exec_valid,
    output  exec_instr_t    exec_instr,
    input   logic           exec_stall
);

    // TODO

endmodule
