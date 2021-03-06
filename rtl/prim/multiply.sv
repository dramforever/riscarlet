module multiply #(
    parameter   integer     A_W     = 32,
    parameter   integer     B_W     = 32,
    localparam  integer     O_W     = A_W + B_W
) (
    input   logic                   clk,
    input   logic                   rst,

    input   logic [A_W - 1 : 0]     a,
    input   logic [B_W - 1 : 0]     b,
    input   logic                   is_signed,
    output  logic [O_W - 1 : 0]     o,

    input   logic                   stb,
    output  logic                   ack
);

    logic [A_W : 0]         a_ext;
    logic [A_W : 0]         b_ext;

    assign a_ext    = { a[A_W - 1] & is_signed, a };
    assign b_ext    = { b[B_W - 1] & is_signed, b };

    logic [O_W + 1 : 0]     result;

    multiply_signed #(
        .A_W(A_W + 1),
        .B_W(B_W + 1)
    ) multiply_signed_i (
        .clk, .rst,
        .a(a_ext), .b(b_ext),
        .o(result),
        .stb, .ack
    );

    assign o = O_W'(result);

    // Unused bits, make Verilator happy
    logic _unused = 1'(result[(A_W + B_W) +: 2]);
endmodule
