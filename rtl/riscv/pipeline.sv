interface pipeline;
    import  types::*;

    logic       valid;
    logic       ready;
    control_t   data;

    modport up (
        input   ready,
        output  valid, data
    );

    modport dn (
        output  valid, data,
        input   ready
    );
endinterface
