# Slightly simplified Wishbone-like bus

The main bus design used in this is inspired by the [Wishbone] bus, specifically
the Wishbone B4 pipelined mode.

[wishbone]: https://www.wishbone-interconnect.org

## Naming convention

- Lower case names are used throughout.
- Direction prefixes (`_i` and `_o`) are dropped.
- Wishbone signal names have a short prefix like `wb_`.

## The `wb_cyc` signal

The `wb_cyc` signal is considered optional to simplify signaling.

- A bus master without a `wb_cyc` output is considered to assert `wb_cyc`
  indefinitely
- A bus slave without a `wb_cyc` input does not use the
