package rscl_bus;
    import rscl_types::*;

    typedef struct packed {
        word_t      addr;
        word_t      data;
        logic       write;
        bsel_t      mask;
    } bus_req_t;
endpackage
