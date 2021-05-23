`define DLY #1

module dx_iobuf_tb ();

wire clk;
wire rst;
tb_base #(
    .TERM_PRD(50)
) tb_base_i (
    .clk(clk),
    .rst(rst)
);

localparam DATA_WIDTH = 8;

reg  dio_t;
reg  [(DATA_WIDTH-1):0] dio_o;
reg  [(DATA_WIDTH-1):0] dio_i_sim;
wire [(DATA_WIDTH-1):0] dio_i;
wire [(DATA_WIDTH-1):0] dio_p;

always @(posedge clk) begin
    dio_t     <= `DLY $random;
    dio_o     <= `DLY $random;
    dio_i_sim <= `DLY $random;
end
assign dio_p = (dio_t == 1'b1) ? dio_i_sim : {DATA_WIDTH{1'bz}};

dx_iobuf #(
    .DATA_WIDTH(DATA_WIDTH)
) dx_iobuf_i (
    .dio_t( {DATA_WIDTH{dio_t}} ),
    .dio_o(dio_o),
    .dio_i(dio_i),
    .dio_p(dio_p)
);

reg flag;
always @(posedge clk) begin
    flag <= `DLY dio_t ? (dio_i == dio_i_sim) : (dio_p == dio_o);
end

endmodule
