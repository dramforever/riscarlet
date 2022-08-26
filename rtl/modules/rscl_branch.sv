module rscl_branch
    import rscl_types::*;
(
    input   word_t  val1,
    input   word_t  val2,

    input   logic   branch_inv,
    input   logic   branch_unsigned,
    input   logic   branch_lt,

    output  logic   taken
);

    wire logic res_lt = (signed'(val1) < signed'(val2));
    wire logic res_ltu = (val1 < val2);
    wire logic res_eq = (val1 == val2);

    assign taken =
        branch_inv
        ^ (branch_lt
            ? (branch_unsigned ? res_ltu : res_lt)
            : res_eq);
endmodule
