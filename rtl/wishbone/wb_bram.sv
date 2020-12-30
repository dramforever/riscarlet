// Wishbone block RAM controller
//
// Requires a block RAM with enable (bram_en) and byte write enable (bram_sel)
// signals. See single_bram for an example.

module wb_bram #(
    parameter integer ADDR_W = 32,
    parameter integer DATA_L = 4
) (
    clk, rst,

    // Block RAM interface
    bram_addr, bram_data_w, bram_data_r, bram_en, bram_sel

    // Wishbone slave
    wb_stb, wb_stall, wb_ack,
    wb_adr, wb_dat_w, wb_dat_r, wb_we, wb_sel
);

    localparam DATA_W = DATA_L * 8;

    input wire  logic                   clk;
    input wire  logic                   rst;

    output      logic [ADDR_W - 1 : 0]  bram_addr;
    output      logic [DATA_W - 1 : 0]  bram_data_w;
    input       logic [DATA_W - 1 : 0]  bram_data_r;
    output      logic                   bram_en;
    output      logic [DATA_L - 1 : 0]  bram_sel;

    input wire  logic                   wb_stb;
    output      logic                   wb_stall;
    output      logic                   wb_ack;
    input wire  logic [ADDR_W - 1 : 0]  wb_adr;
    input wire  logic [DATA_W - 1 : 0]  wb_dat_w;
    output      logic [DATA_W - 1 : 0]  wb_dat_r;
    input wire  logic                   wb_we;
    input wire  logic [DATA_L - 1 : 0]  wb_sel;

    assign bram_addr = wb_adr;
    assign bram_data_w = wb_dat_w;
    assign bram_en = wb_stb;
    assign bram_sel = (wb_stb && wb_we) ? wb_sel : '0;

    assign wb_stall = '0;
    assign wb_dat_r = bram_data_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            wb_ack <= '0;
        end else begin
            wb_ack <= wb_stb;
        end
    end

endmodule
