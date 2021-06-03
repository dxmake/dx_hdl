`timescale 1ns / 100ps
`define DLY #1

module dx_reg #(
    parameter DATA_WIDTH = 1
) (
    input  wire clk,
    input  wire [(DATA_WIDTH-1):0] din,
    output reg  [(DATA_WIDTH-1):0] dout
);

always @(posedge clk) begin
    dout <= `DLY din;
end

endmodule
