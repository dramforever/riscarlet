module multiply_signed #(
    parameter   integer     A_W     = 32,
    parameter   integer     B_W     = 32,
    localparam  integer     O_W     = A_W + B_W
) (
    input   logic                   clk,
    input   logic                   rst,

    input   logic [A_W - 1 : 0]     a,
    input   logic [B_W - 1 : 0]     b,
    output  logic [O_W - 1 : 0]     o,

    input   logic                   stb,
    output  logic                   ack
);
    logic [B_W - 1 : 0]         delay;

    always_ff @(posedge clk) begin
        if (rst) begin
            delay <= '0;
        end else begin
            delay <= { delay[B_W - 2 : 0], stb && ! running };
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            ack <= '0;
        end else begin
            ack <= delay[B_W - 1];
        end
    end

    logic running;

    always_ff @(posedge clk) begin
        if (rst) begin
            running <= '0;
        end else begin
            if (running) begin
                running <= ~ delay[B_W - 1];
            end else if (stb) begin
                running <= '1;
            end
        end
    end

    logic [A_W - 1 : 0]         a_saved;

    always_ff @(posedge clk) begin
        if (stb && ! running) begin
            a_saved <= a;
        end
    end

    logic [O_W : 0]   result;
    logic [O_W : 0]   result_next;

    always_comb begin
        result_next = result;

        unique case (result[1:0])
            2'b01:      result_next[O_W -: A_W] += a_saved;
            2'b10:      result_next[O_W -: A_W] -= a_saved;
            default:;   // Nothing
        endcase

        result_next = {
            result_next[O_W],
            result_next[O_W : 1]
        };
    end

    always_ff @(posedge clk) begin
        if (running) begin
            result <= result_next;
        end else if (stb) begin
            result <= { A_W'('0), b, 1'b0 };
        end
    end

    assign o = result[O_W : 1];
endmodule
