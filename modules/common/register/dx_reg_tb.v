`define DLY #1

module dx_reg_tb ();

wire clk;
wire rst;
tb_base #(
    .TERM_PRD(50)
) tb_base_i (
    .clk(clk),
    .rst(rst)
);

localparam DATA_WIDTH = 8;

reg  [(DATA_WIDTH-1):0] din;
reg  [(DATA_WIDTH-1):0] din_dly;
wire [(DATA_WIDTH-1):0] dout;

always @(posedge clk) begin
    din     <= `DLY $random;
    din_dly <= `DLY din;
end

dx_reg #(
    .DATA_WIDTH(DATA_WIDTH)
) dx_reg_i (
    .clk(clk),
    .din(din),
    .dout(dout)
);

reg flag;
always @(posedge clk) begin
    flag <= (din_dly == dout);
end

endmodule
