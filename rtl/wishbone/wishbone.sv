interface wishbone;
    import  types::*;

    logic       stb;
    logic       stall;
    logic       ack;

    word_t      adr;
    bsel_t      sel;
    logic       we;
    word_t      dat_r;
    word_t      dat_w;

    modport master (
        input   dat_r, stall, ack,
        output  stb, adr, sel, we, dat_w
    );

    modport slave (
        output  dat_r, stall, ack,
        input   stb, adr, sel, we, dat_w
    );
endinterface
