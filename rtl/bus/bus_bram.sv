// Block RAM controller
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
    output  logic       bram_we,
    output  bsel_t      bram_sel,

    bus_req_c.dn       req,
    bus_rsp_c.up       rsp,
);

    assign bram_addr = req.data.addr[$bits() - 1 : 2];
    assign bram_data_w = req.data.w_data;
    assign bram_en = req.valid && req.ready;
    assign bram_we = req.data.we;

    assign req.ready = rsp.ready;
    assign wb.dat_r = bram_data_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            rsp.valid <= '0;
        end else begin
            rsp.valid <= (req.valid && rsp.ready);
        end
    end

endmodule
