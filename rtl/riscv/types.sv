package types;
    typedef logic [31:0]    word_t;
    typedef logic [3:0]     bsel_t;

    typedef logic [31:0]    instr_t;
    typedef logic [4:0]     rnum_t;
    typedef logic [6:0]     opcode_t;
    typedef logic [6:0]     funct7_t;
    typedef logic [2:0]     funct3_t;

    typedef struct packed {
        opcode_t    opcode;

        rnum_t      rs1;
        rnum_t      rs2;
        rnum_t      rd;

        funct3_t    funct3;
        funct7_t    funct7;

        word_t      imm_i;
        word_t      imm_s;
        word_t      imm_b;
        word_t      imm_u;
        word_t      imm_j;
    } instr_fields_t;

    function automatic instr_fields_t instr_fields (
        instr_t in
    );
        return '{
            opcode:     {>>{in[6:0]}},
            rs1:        in[15 +: $bits(rnum_t)],
            rs2:        in[20 +: $bits(rnum_t)],
            rd:         in[7  +: $bits(rnum_t)],

            funct3:     in[12 +: 3],
            funct7:     in[25 +: 7],

            imm_i:      {{21{in[31]}}, in[20 +: 11]},
            imm_s:      {{21{in[31]}}, in[25 +: 6], in[7 +: 5]},
            imm_b:      {{20{in[31]}}, in[7], in[25 +: 6], in[8 +: 4], 1'b0},
            imm_u:      {in[12 +: 20], 12'b0},
            imm_j:      {{12{in[31]}}, in[12 +: 8], in[20], in[21 +: 10], 1'b0}
        };
    endfunction
endpackage
