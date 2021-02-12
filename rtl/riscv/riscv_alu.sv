module riscv_alu
    import types::*;
(
    input   word_t      a,
    input   word_t      b,
    input   logic       is_imm,
    input   funct7_t    funct7,
    input   funct3_t    funct3,
    output  word_t      o
);

    localparam funct3_t ALU_ADD_SUB     = 3'b000;
    localparam funct3_t ALU_SLL         = 3'b001;
    localparam funct3_t ALU_SLT         = 3'b010;
    localparam funct3_t ALU_SLTU        = 3'b011;
    localparam funct3_t ALU_XOR_XNOR    = 3'b100;
    localparam funct3_t ALU_SRL_SRA     = 3'b101;
    localparam funct3_t ALU_OR          = 3'b110;
    localparam funct3_t ALU_AND         = 3'b111;

    always_comb begin
        unique case (is_imm ? '0 : funct7)
            7'b000_0000:
                unique case (funct3)
                    ALU_ADD_SUB:    o = a + b;
                    ALU_SLL:        o = a << b[4:0];
                    ALU_SLT:        o = ($bits(word_t))'($signed(a) < $signed(b));
                    ALU_SLTU:       o = ($bits(word_t))'(a < b);
                    ALU_XOR_XNOR:   o = a ^ b;
                    ALU_SRL_SRA:    o = a >> b[4:0];
                    ALU_OR:         o = a | b;
                    ALU_AND:        o = a & b;
                    default:        o = '0;
                endcase
            7'b010_0000:
                unique case (funct3)
                    ALU_ADD_SUB:    o = a - b;
                    ALU_XOR_XNOR:   o = a ^ (~ b);
                    ALU_SRL_SRA:    o = $signed(a) >>> b[4:0];
                    default:        o = '0;
                endcase
            default: begin
                o = '0;
            end
        endcase
    end
endmodule
