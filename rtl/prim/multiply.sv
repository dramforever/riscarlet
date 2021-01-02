`default_nettype none
`timescale 1ns/1ps

module multiply #(
    parameter integer   A_W     = 32,
    parameter integer   B_W     = 32,
    parameter integer   O_W     = A_W + B_W
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
    logic [(B_W + 1) - 1 : 0]         delay;

    always_ff @(posedge clk) begin
        if (rst) begin
            delay <= '0;
        end else begin
            delay <= { delay[B_W - 1 : 0], stb && ! running };
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            ack <= '0;
        end else begin
            ack <= delay[B_W];
        end
    end

    logic running;

    always_ff @(posedge clk) begin
        if (rst) begin
            running <= '0;
        end else begin
            if (running) begin
                running <= ~ delay[B_W];
            end else if (stb) begin
                running <= '1;
            end
        end
    end

    logic [A_W - 1 : 0]         a_saved;
    logic                       is_signed_saved;

    always_ff @(posedge clk) begin
        if (stb && ! running) begin
            a_saved <= a;
            is_signed_saved <= is_signed;
        end
    end

    logic [(A_W + 1) - 1 : 0]   a_ext;

    assign a_ext = { is_signed_saved & a_saved[A_W - 1], a_saved };

    logic [(O_W + 3) - 1 : 0]   result;
    logic [(O_W + 3) - 1 : 0]   result_next;

    always_comb begin
        result_next = result;

        unique case (result[1:0])
            2'b01:      result_next[(O_W + 3) - 1 -: A_W + 1] += a_ext;
            2'b10:      result_next[(O_W + 3) - 1 -: A_W + 1] -= a_ext;
            default:;   // Nothing
        endcase

        result_next = {
            result_next[(O_W + 3) - 1],
            result_next[(O_W + 3) - 1 : 1]
        };
    end

    always_ff @(posedge clk) begin
        if (running) begin
            result <= result_next;
        end else if (stb) begin
            result <= { 1'b0, A_W'('0), is_signed & b[B_W - 1], b, 1'b0 };
        end
    end

    assign o = result[O_W : 1];
endmodule
