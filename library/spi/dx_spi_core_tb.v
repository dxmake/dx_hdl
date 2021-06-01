`timescale 1ns / 1ps
`define DLY #1

module dx_spi_core_tb ();

localparam HALF_PRD_NS = 5;
localparam FULL_PRD_NS = 2 * HALF_PRD_NS;
localparam RST_PRD     = 4;

wire clk;
wire rst;

// ==== under testing model ===================================================
localparam DATA_WIDTH = 16;
localparam DATA_COUNT_WIDTH = 8;
localparam SCLK_COUNT_WIDTH = 16;

localparam SPI_WIDTH = 8'd8;  // >= 1
localparam CPOL = 1'b0;
localparam CPHA = 1'b0;
localparam SCLK_DIV = 16'd2;  // >= 1

reg mosi_stb;
reg [DATA_WIDTH-1:0] mosi_data;
wire miso_stb;
wire [DATA_WIDTH-1:0] miso_data;

wire ready;
wire [2:0] state;
wire [DATA_COUNT_WIDTH-1:0] data_count;
wire wr_edge;
wire rd_edge;

wire sclk;
wire mosi;
wire miso;
wire csn;

dx_spi_core #(
	.DATA_WIDTH(DATA_WIDTH),
	.DATA_COUNT_WIDTH(DATA_COUNT_WIDTH),
	.SCLK_COUNT_WIDTH(SCLK_COUNT_WIDTH)
) dx_spi_core_i (
	.clk(clk),
	.rst(rst),

	.spi_width_i(SPI_WIDTH),
	.cpol_i(CPOL),
	.cpha_i(CPHA),
	.sclk_div_i(SCLK_DIV),
	
	.mosi_stb(mosi_stb),
	.mosi_data_i(mosi_data),
	.miso_stb(miso_stb),
	.miso_data_o(miso_data),
	
	.ready_o(ready),
	.state_o(state),
	.data_count_o(data_count),
	.wr_edge(wr_edge),
	.rd_edge(rd_edge),
	
	.sclk(sclk),
	.mosi(mosi),
	.miso(miso),
	.csn(csn)
);

assign miso = mosi;

reg [SPI_WIDTH-1:0] send_data;
reg flag;   // result is right.
always @(posedge clk) begin
    if((mosi_stb & ready) | (mosi_stb & miso_stb)) begin
        send_data <= `DLY mosi_data[DATA_WIDTH-1:DATA_WIDTH-SPI_WIDTH];
    end
    
    if(miso_stb) begin
        flag <= `DLY (miso_data[SPI_WIDTH-1:0] == send_data);
    end
end




// ==== stimulating signals from FPGA side ====================================
localparam SPI_START_PRD = RST_PRD + 20;
localparam SCLK_PRD_PRD = 2 * (SCLK_DIV+1); // frequency division ratio.
localparam SPI_WORD_PRD = (SPI_WIDTH+1) * SCLK_PRD_PRD + 1; // transmit one word costs.
localparam SPI_GAP_PRD = 10; // simulation setting, >=0, periods between two spi transmission.
localparam SPI_RPT_PRD = SPI_WORD_PRD + SPI_GAP_PRD;
localparam SPI_WORD_NUM = 5; // simulation setting, how many words to send.


localparam SPI_START_NS = SPI_START_PRD * FULL_PRD_NS;
localparam SPI_RPT_NS = SPI_RPT_PRD * FULL_PRD_NS - FULL_PRD_NS;
initial begin
	mosi_stb = 1'b0;
	mosi_data = {DATA_WIDTH{1'b0}};
	#SPI_START_NS;
	`DLY;
	repeat(SPI_WORD_NUM) begin
		mosi_stb = 1'b1;
		mosi_data = $random;
		#FULL_PRD_NS;
		mosi_stb = 1'b0;
		mosi_data = {DATA_WIDTH{1'b0}};
		#SPI_RPT_NS;
	end
end

// ==== clk and rst ===========================================================
localparam TERM_PRD = SPI_START_PRD + SPI_WORD_NUM * SPI_RPT_PRD + 100;
tb_base #(
    .TERM_PRD(TERM_PRD)
) tb_base_i (
    .clk(clk),
    .rst(rst)
);

endmodule
