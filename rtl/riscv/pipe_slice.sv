module pipe_slice (
    input   logic   clk,
    input   logic   rst,

    pipeline.up     up,
    pipeline.dn     dn
);
    assign up.ready = dn.ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            dn.valid <= '0;
        end else if (dn.ready)
            dn.valid <= up.valid;
    end

    always_ff @(posedge clk) begin
        if (dn.ready && up.valid)
            dn.data <= up.data;
    end
endmodule
