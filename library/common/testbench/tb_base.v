`timescale 1ns / 100ps
`define DLY #1
// set clk and rst for testbench,
// and terminate the simulation after TERM_PRD periods.
module tb_base #(
    parameter HALF_PRD_NS = 5,  // default for 100MHz
    parameter RST_PRD     = 4,  // after 4 periods, rst pull down
    parameter TERM_PRD    = 10000
) (
    output reg clk,
    output reg rst      // high effective reset.
);

parameter FULL_PRD_NS = 2 * HALF_PRD_NS;

initial begin
    clk = 1'b1;
    forever begin
        #HALF_PRD_NS clk = 1'b0;
        #HALF_PRD_NS clk = 1'b1;
    end
end

initial begin
    rst = 1'b1;
    repeat(RST_PRD) begin
        #FULL_PRD_NS;
    end
    `DLY;
    rst = 1'b0;
end


localparam TERM_NS = TERM_PRD * FULL_PRD_NS;
initial begin
    #TERM_NS $finish;
end

endmodule
