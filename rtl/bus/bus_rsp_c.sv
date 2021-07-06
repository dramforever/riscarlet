interface bus_rsp_c;
    bus::rsp_t   data;
    logic   ready;
    logic   valid;

    modport up (
        output data,
        output valid,
        input ready
    );

    modport dn (
        input data,
        input valid,
        output ready
    );
endinterface