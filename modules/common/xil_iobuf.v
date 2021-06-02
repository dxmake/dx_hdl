module xil_iobuf #(
    parameter DATA_WIDTH = 1
) (
    input  wire [(DATA_WIDTH-1):0] dio_i,
    output wire [(DATA_WIDTH-1):0] dio_o,
    input  wire [(DATA_WIDTH-1):0] dio_t,
    // dio_t = 1, for input  at inout port, out_sig -> dio_p -> dio_o
    // dio_t = 0, for output at inout port, out_sig <- dio_p <- dio_i
    inout  wire [(DATA_WIDTH-1):0] dio_p
);

genvar n;
generate
    for (n = 0; n < DATA_WIDTH; n = n+1) begin: g_xil_iobuf
        IOBUF IOBUF_xil (
            .I (dio_i[n]),
            .O (dio_o[n]),
            .T (dio_t[n]),
            .IO(dio_p[n])
        );
    end
endgenerate

endmodule
