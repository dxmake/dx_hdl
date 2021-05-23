module dx_iobuf #(
    parameter DATA_WIDTH = 1
) (
    input  wire [(DATA_WIDTH-1):0] dio_t,
    // dio_t = 1, for input  at inout port, out_sig -> dio_p -> dio_i
    // dio_t = 0, for output at inout port, out_sig <- dio_p <- dio_o
    input  wire [(DATA_WIDTH-1):0] dio_o,
    output wire [(DATA_WIDTH-1):0] dio_i,
    inout  wire [(DATA_WIDTH-1):0] dio_p
);

genvar n;
generate
    for (n = 0; n < DATA_WIDTH; n = n+1) begin: g_dx_iobuf
        // assign dio_i[n] = (dio_t[n] == 1'b1) ? dio_p[n] : 1'b0;
        assign dio_i[n] = dio_p[n];
        assign dio_p[n] = (dio_t[n] == 1'b1) ? 1'bz     : dio_o[n];
    end
endgenerate

endmodule
