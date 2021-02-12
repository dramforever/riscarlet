# RIScarlet: RISC-V in Scarlet

*(This is a work in progress)*

Maybe one day I will be able to build a 'full' RISC-V core...

## Goals

- Most of RV32I
    - Naturally aligned memory access only
    - No `fence`
    - No `ecall` and `ebreak`
- Pipelined
- Operand forwarding
- Simple branch prediction
    - Build static not-taken first
- Pipelined memory access

## Disclaimer

For the student finding this:

Please make sure to follow relevant lab assignment rules when using this code.
Plagarism and cheating is always unacceptable. RIScarlet being available as free
software does not mean you can ignore other rules and evade responsibility.
