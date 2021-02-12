interface pipeline;
    import  types::*;

    logic       valid;
    logic       ready;

    /* verilator lint_off UNUSED */
    control_t   data;
    /* verilator lint_on UNUSED */

    modport up (
        input   ready,
        output  valid, data
    );

    modport dn (
        output  valid, data,
        input   ready
    );
endinterface
