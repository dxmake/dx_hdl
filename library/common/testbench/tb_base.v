`timescale 1ns / 100ps
// set clk and rst for testbench,
// and terminate the simulation after TERM_PRD_NUM periods.
module tb_base #(
    parameter HALF_PRD_NS = 5,  // default for 100MHz
    parameter RST_PRD_NUM = 4,  // after 4 periods, rst pull down
    parameter TERM_PRD_NUM = 10000
) (
    output reg clk,
    output reg rst      // high effective reset.
);

initial begin
    clk = 1'b1;
    forever begin
        #HALF_PRD_NS clk = 1'b0;
        #HALF_PRD_NS clk = 1'b1;
    end
end

localparam RST_NS = RST_PRD_NUM * 2 * HALF_PRD_NS;
initial begin
    rst = 1'b1;
    #RST_NS rst = 1'b0;
end

localparam TERM_NS = TERM_PRD_NUM * 2 * HALF_PRD_NS;
initial begin
    #TERM_NS $finish;
end

endmodule
