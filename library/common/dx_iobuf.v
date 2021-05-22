module dx_iobuf #(
    parameter DATA_WIDTH = 1
) (
    input  wire [(DATA_WIDTH-1):0] dio_t,
    // dio_t = 1, for input  at inout port, out_sig -> dio_p -> dio_o
    // dio_t = 0, for output at inout port, out_sig <- dio_p <- dio_i
    input  wire [(DATA_WIDTH-1):0] dio_i,
    output wire [(DATA_WIDTH-1):0] dio_o,
    inout  wire [(DATA_WIDTH-1):0] dio_p
);

genvar n;
generate
    for (n = 0; n < DATA_WIDTH; n = n + 1) begin
        assign dio_o[n] = dio_p[n];
        assign dio_p[n] = (dio_t[n] == 1'b1) ? 1'bz : dio_i[n];
    end
endgenerate

endmodule
