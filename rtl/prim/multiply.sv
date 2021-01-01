`default_nettype none
`timescale 1ns/1ps

module multiply #(
    parameter integer   A_W     = 32,
    parameter integer   B_W     = 32,
    parameter integer   O_W     = A_W + B_W,
    localparam integer  CTR_W   = $clog2(B_W)
) (
    input wire  logic                   clk,
    input wire  logic                   rst,

    input wire  logic [A_W - 1 : 0]     a,
    input wire  logic [B_W - 1 : 0]     b,
    input wire  logic                   is_signed,
    output      logic [O_W - 1 : 0]     o,

    input wire  logic                   stb,
    output      logic                   ack
);

    logic [B_W - 1 : 0]     b_plus;
    logic [B_W - 1 : 0]     b_minus;

    always_comb begin
        if (is_signed) begin
            b_plus = (~b) & (b << 1);
            b_minus = b & ~(b << 1);
        end else begin
            b_plus = b;
            b_minus = 'd0;
        end
    end

    logic                   running;
    logic [CTR_W - 1 : 0]   counter;
    logic [A_W - 1 : 0]     a_saved;
    logic [B_W - 1 : 0]     b_plus_saved;
    logic [B_W - 1 : 0]     b_minus_saved;

    logic [O_W - 1 : 0]     a_saved_ext;
    assign a_saved_ext = {
        {(O_W - A_W){ a_saved[O_W - 1] & is_signed }},
        a_saved
    };

    always_ff @(posedge clk) begin
        if (rst) begin
            running <= '0;
            ack <= '0;
        end else begin
            if (running) begin
                unique case (1'b1)
                    b_plus_saved[B_W - 1]:
                        o <= (o << 1) + O_W'(a_saved_ext);
                    b_minus_saved[B_W - 1]:
                        o <= (o << 1) - O_W'(a_saved_ext);
                    default:
                        o <= (o << 1);
                endcase

                if (counter == 'd0) begin
                    ack <= '1;
                    running <= '0;
                end

                counter <= counter - 'd1;
                b_plus_saved <= b_plus_saved << 1;
                b_minus_saved <= b_minus_saved << 1;
            end else begin
                ack <= '0;

                if (stb) begin
                    a_saved <= a;
                    b_plus_saved <= b_plus;
                    b_minus_saved <= b_minus;
                    counter <= CTR_W'(B_W - 1);
                    running <= '1;
                    o <= 'd0;
                end
            end
        end
    end
endmodule
