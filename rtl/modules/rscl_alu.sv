module rscl_alu
    import rscl_types::*;
    import rscl_instr::*;
(
    input   word_t      val1,
    input   word_t      val2,
    input   alu_f3_t    funct3,
    input   funct7_t    funct7,

    output  word_t      out
);

    always_comb begin
        case (funct3)
        alu_add_sub:    out = funct7[5] ? (val1 + val2) : (val1 - val2);
        alu_sll:        out = val1 << val2[4:0];
        alu_slt:        out = (signed'(val1) < signed'(val2)) ? 'd1 : 'd0;
        alu_sltu:       out = (val1 < val2) ? 'd1 : 'd0;
        alu_xor:        out = val1 ^ val2;
        alu_srl_sra:    out = funct7[5] ? (val1 >> val2[4:0]) : (signed'(val1) >> val2[4:0]);
        alu_or:         out = val1 | val2;
        alu_and:        out = val1 & val2;
        endcase
    end

    wire funct7_t funct7_unused = funct7;
endmodule
