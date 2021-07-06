interface bus_req_c;
    bus::req_t   data;
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
