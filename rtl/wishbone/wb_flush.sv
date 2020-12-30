// Wishbone bus wrapper for flushing
//
// Wrapper around a Wishbone slave interface to allow flushing all outstanding
// requests.

module wb_flush #(
    parameter integer MAX_OUTSTANDING = 1;
    parameter integer COUNTER_W = $clog2(MAX_OUTSTANDING)
    parameter integer ADDR_W = 32,
    parameter integer DATA_L = 4
) (
    clk, rst,

);

endmodule
