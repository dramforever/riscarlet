// Single port block RAM
//
// RTL implementation of a single-port block ram with single stage of
// pipelining. A synthesis tool should be able to infer a block RAM from this.

module single_bram #(
    parameter integer   ADDR_W  = 14,
    parameter integer   SIZE    = 1 << ADDR_W,
    parameter integer   DATA_L  = 4
) (
    input   logic                   clk,

    input   logic [ADDR_W - 1 : 0]  addr,
    input   logic [DATA_W - 1 : 0]  data_w,
    output  logic [DATA_W - 1 : 0]  data_r,
    input   logic                   en,
    input   logic                   we,
    input   logic [DATA_L - 1 : 0]  sel
);

    localparam integer  DATA_W  = DATA_L * 8;

    (* ram_style = "block" *)
    logic [DATA_W - 1 : 0]  mem [SIZE - 1 : 0];

    integer i;

    always_ff @(posedge clk) begin
        if (en) begin
            if (we) begin
                for (i = 0; i != DATA_L; i ++) begin
                    if (sel[i]) begin
                        mem[addr][i * 8 +: 8] <= data_w[i * 8 +: 8];
                    end
                end
            end
            data_r <= mem[addr];
        end
    end

endmodule
