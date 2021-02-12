interface regport
    import  types::*;

    rnum_t      num;
    logic       ready;
    word_t      value;

    modport up (
        input   num
        output  ready, value
    );

    modport dn (
        output  ready, value,
        input   num
    );
endinterface
