package rscl_instr;
    import rscl_types::*;

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

    typedef enum funct3_t {
        alu_add_sub     = 'b000,
        alu_sll         = 'b001,
        alu_slt         = 'b010,
        alu_sltu        = 'b011,
        alu_xor         = 'b100,
        alu_srl_sra     = 'b101,
        alu_or          = 'b110,
        alu_and         = 'b111
    } alu_f3_t;

    typedef struct packed {
        rnum_t      rs1;
        rnum_t      rs2;
        rnum_t      rd;
        word_t      imm;

        logic       write_rd;

        logic       trap;
        logic       trap_int;
        cause_t     trap_cause;

        logic       is_utype;
        logic       utype_add_pc;

        logic       is_alu;
        logic       alu_reg;
        alu_f3_t    alu_funct3;
        funct7_t    alu_funct7;

        logic       is_branch;
        logic       branch_inv;
        logic       branch_unsigned;
        logic       branch_lt;

        logic       is_jal;
        logic       is_jalr;

        logic       is_mem;
        logic       mem_store;
        logic [1:0] mem_width;
        logic       mem_unsigned;

        logic       is_csr;
        csr_num_t   csr_num;
        logic       csr_imm;
        logic [1:0] csr_op;

        logic       is_misc_mem;
        logic       misc_mem_fence_i;

        logic       is_wfi;
        logic       is_mret;
    } decoded_instr_t;

    typedef struct packed {
        word_t      pc;

        logic       trap;
        logic       trap_int;
        cause_t     trap_cause;
        word_t      trap_val;

        // Following valid only if (!trap)

        logic       is_mem;
        logic       is_mret;
        logic       is_fence_i;

        logic       write_rd;
        rnum_t      rd;
        word_t      rd_value;

        logic       write_csr;
        csr_num_t   csr_num;
        word_t      csr_val;
    } exec_instr_t;

    function automatic instr_fields_t instr_fields (
        instr_t in
    );
        return '{
            opcode:     in[6:0],
            rs1:        in[15 +: 5],
            rs2:        in[20 +: 5],
            rd:         in[7  +: 5],

            funct3:     in[12 +: 3],
            funct7:     in[25 +: 7],

            imm_i:      {{21{in[31]}}, in[20 +: 11]},
            imm_s:      {{21{in[31]}}, in[25 +: 6], in[7 +: 5]},
            imm_b:      {{20{in[31]}}, in[7], in[25 +: 6], in[8 +: 4], 1'b0},
            imm_u:      {in[12 +: 20], 12'b0},
            imm_j:      {{12{in[31]}}, in[12 +: 8], in[20], in[21 +: 10], 1'b0}
        };
    endfunction

    function automatic decoded_instr_t decode_instr (
        instr_t in
    );
        instr_fields_t fields;
        decoded_instr_t res;

        fields = instr_fields(in);

        res.rs1 = fields.rs1;
        res.rs2 = fields.rs2;
        res.rd = fields.rd;

        res.trap = '0;
        res.trap_int = '0;
        res.trap_cause = 'd2; // Illegal

        // Instruction type

        res.is_utype = '0;
        res.is_alu = '0;
        res.is_branch = '0;
        res.is_jal = '0;
        res.is_jalr = '0;
        res.is_csr = '0;
        res.is_misc_mem = '0;

        res.is_wfi = '0;
        res.is_mret = '0;

        unique case (fields.opcode) inside
            'b0?1_0111: res.is_utype = '1;
            'b110_1111: res.is_jal = '1;
            'b110_0111: res.is_jalr = '1;
            'b110_0011: res.is_branch = '1;
            'b0?0_0011: res.is_mem = '1;
            'b0?1_0011: res.is_alu = '1;
            'b000_1111: res.is_misc_mem = '1;

            'b111_0011: begin
                // system
                unique if (in == 'h30200073)
                    res.is_mret = '1;
                else if (in == 'h10500073)
                    res.is_wfi = '1;
                else if (fields.funct3[1:0] != 'b00)
                    res.is_csr = '1;
                else
                    res.trap = '1;
            end

            default:    res.trap = '1;
        endcase

        // Fields

        // is_utype
        res.utype_add_pc = fields.opcode[5];

        // is_alu
        res.alu_reg = fields.opcode[5];
        res.alu_funct3 = alu_f3_t'(fields.funct3);
        res.alu_funct7 = (res.alu_reg || res.alu_funct3 == alu_srl_sra) ? fields.funct7 : '0;

        // is_branch
        res.branch_inv = fields.funct3[0];
        res.branch_unsigned = fields.funct3[1];
        res.branch_lt = fields.funct3[2];

        // is_mem
        res.mem_store = fields.opcode[5];
        res.mem_width = fields.funct3[1:0];
        res.mem_unsigned = fields.funct3[2];

        // is_csr
        res.csr_num = fields.imm_i[11:0];
        res.csr_imm = fields.funct3[2];
        res.csr_op = fields.funct3[1:0];

        // is_misc_mem
        res.misc_mem_fence_i = (fields.funct3 == 'b001);

        unique case (1'b1)
        res.is_utype:   res.imm = fields.imm_u;
        res.is_alu:     res.imm = fields.imm_i;
        res.is_branch:  res.imm = fields.imm_b;
        res.is_jal:     res.imm = fields.imm_j;
        res.is_jalr:    res.imm = fields.imm_i;
        res.is_csr:     res.imm = {($bits(word_t) - $bits(rnum_t))'('0), fields.rs1};
        res.is_mem:     res.imm = res.mem_store ? fields.imm_s : fields.imm_i;
        default:        res.imm = 'x;
        endcase

        unique case (1'b1)
        res.is_utype:   res.write_rd = '1;
        res.is_alu:     res.write_rd = '1;
        res.is_branch:  res.write_rd = '1;
        res.is_jal:     res.write_rd = '1;
        res.is_jalr:    res.write_rd = '1;
        res.is_csr:     res.write_rd = '1;
        res.is_mem:     res.write_rd = ! res.mem_store;
        default:        res.write_rd = '0;
        endcase

        return res;
    endfunction
endpackage
