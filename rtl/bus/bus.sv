package bus;
    import types::*;

    typedef struct packed {
        logic   we;
        word_t  addr;
        word_t  w_data;
        bsel_t  bstb;
    } req_t;

    typedef struct packed {
        word_t  r_data;
    } rsp_t;
endpackage
