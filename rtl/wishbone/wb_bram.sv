// Wishbone block RAM controller
//
// Requires a block RAM with enable (bram_en) and byte write enable (bram_sel)
// signals. See single_bram for an example.
//
// Use *word address* for bram_addr port and *word address* width for
// BRAM_ADDR_W.

module wb_bram #(
    parameter   integer     BRAM_ADDR_W = 14;
)
    import types::*;
(
    input   logic       clk,
    input   logic       rst,

    // Block RAM
    output  logic [BRAM_ADDR_W - 1 : 0] bram_addr,
    output  word_t      bram_data_w,
    input   word_t      bram_data_r,
    output  logic       bram_en,
    output  bsel_t      bram_sel,

    wishbone.slave          wb;
);

    assign bram_addr = wb.adr[$bits() - 1 : 2];
    assign bram_data_w = wb.dat_w;
    assign bram_en = wb.stb;
    assign bram_sel = (wb.stb && wb.we) ? wb.sel : '0;

    assign wb.stall = '0;
    assign wb.dat_r = bram_data_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            wb.ack <= '0;
        end else begin
            wb.ack <= wb.stb;
        end
    end

endmodule
