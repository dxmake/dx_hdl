`timescale 1ns / 100ps
`define DLY #1

// this module can test 4-wire mode, 3-wire r/w mode at the same time.
// DATA_WIDTH, SPI_WIDTH, WRITE_BITS, READ_MODE, CPOL, CPHA, are configable

module dx_spi_m4s3_tb ();

localparam HALF_PRD_NS = 5;
localparam FULL_PRD_NS = 2 * HALF_PRD_NS;
localparam RST_PRD     = 4;

wire clk;
wire rst;

// ==== under testing model ===================================================
localparam DATA_WIDTH = 32;
localparam DATA_COUNT_WIDTH = 8;
localparam SCLK_COUNT_WIDTH = 16;

localparam SPI_WIDTH = 8'd24;  // >= 1
localparam CPOL = 1'b0;
localparam CPHA = 1'b0;
localparam SCLK_DIV = 16'd3;  // >= 1

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
wire mosi_m;
wire miso_m;
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
	.mosi(mosi_m),
	.miso(miso_m),
	.csn(csn)
);


localparam WRITE_BITS = 16;
localparam READ_BITS = SPI_WIDTH-WRITE_BITS;
localparam READ_MODE = 1'b1;

reg [2:0] csn_mul;
wire miso_s;
wire sdio_s;
wire s3_mode;
dx_spi_m4s3 #(
    .CSN_NUM(3),
    .S3_EN(3'b100),
    .CPOL({3{CPOL}}),
    .CPHA({3{CPHA}}),
    .READ({READ_MODE, 2'b00}),
    .WRITE_BITS(WRITE_BITS),
    .DATA_COUNT_WIDTH(DATA_COUNT_WIDTH)
) dx_spi_m4s3_i (
    .sclk(sclk),
    .mosi_m(mosi_m),
    .miso_m(miso_m),
    .csn(csn_mul),

    .miso_s(miso_s),
    .sdio_s(sdio_s),
    
    .s3_mode(s3_mode)
);

// 4-wire is in loop test.
wire mosi_s;
assign mosi_s = mosi_m;
assign miso_s = mosi_s;

// 3-wire write part is loop by dx_iobuf,
// 3-wire read  part is generated.
reg rd_mode;
reg sdio_s_in;
assign sdio_s = (s3_mode & rd_mode & (data_count>WRITE_BITS) & (data_count<=SPI_WIDTH)) ?
        sdio_s_in : 1'bz;


reg  [SPI_WIDTH-1:0]  s4_send_data;
wire [WRITE_BITS-1:0] s3_p1_data;
wire [READ_BITS-1:0]  s3_p2_data;
reg [READ_BITS-1:0] s3_recv_data;
assign s3_p1_data = s4_send_data[SPI_WIDTH-1:READ_BITS];
assign s3_p2_data = (s3_mode & rd_mode) ? s3_recv_data : s4_send_data[READ_BITS-1:0];
wire s4_flag;      // 4-wire is right.
wire s3_p1_flag;   // 3-wire part one for write is right.
wire s3_p2_flag;   // 3-wire part two for r/w   is right.
assign s4_flag = (miso_data[SPI_WIDTH-1:0] == s4_send_data);
assign s3_p1_flag = (miso_data[SPI_WIDTH-1:READ_BITS] == s3_p1_data);
assign s3_p2_flag = (miso_data[READ_BITS-1:0] == s3_p2_data);
reg flag;
always @(posedge clk) begin
    if((mosi_stb & ready) | (mosi_stb & miso_stb)) begin
        s4_send_data <= `DLY mosi_data[DATA_WIDTH-1:DATA_WIDTH-SPI_WIDTH];
        rd_mode <= `DLY (mosi_data[DATA_WIDTH-1] == READ_MODE);
    end
    
    if(miso_stb) begin
        if(s3_mode) begin
            flag <= `DLY (s3_p1_flag & s3_p2_flag);
        end else begin
            flag <= `DLY s4_flag;
        end
    end
end


// ==== stimulating signals from FPGA side ====================================
localparam SPI_START_PRD = RST_PRD + 20;
localparam SCLK_PRD_PRD = 2 * (SCLK_DIV+1); // frequency division ratio.
localparam SPI_WORD_PRD = (SPI_WIDTH+1) * SCLK_PRD_PRD + 1; // transmit one word costs.
localparam SPI_GAP_PRD = 10; // simulation setting, >=0, periods between two spi transmission.
localparam SPI_RPT_PRD = SPI_WORD_PRD + SPI_GAP_PRD;
localparam SPI_WORD_NUM = 100; // simulation setting, how many words to send.


localparam SPI_START_NS = SPI_START_PRD * FULL_PRD_NS;
localparam SPI_RPT_NS = SPI_RPT_PRD * FULL_PRD_NS - FULL_PRD_NS;
reg [1:0] csn_sel;
initial begin
	mosi_stb = 1'b0;
	mosi_data = {DATA_WIDTH{1'b0}};
	#SPI_START_NS;
    `DLY;
	repeat(SPI_WORD_NUM) begin
		mosi_stb = 1'b1;
		// mosi_data[DATA_WIDTH-1] = 1'b1;
		// mosi_data[DATA_WIDTH-2:0] = $random;
		mosi_data = $random;
		csn_sel = $random;
		#FULL_PRD_NS;
		mosi_stb = 1'b0;
		mosi_data = {DATA_WIDTH{1'b0}};
		#SPI_RPT_NS;
	end
end

always @(*) begin
    case(csn_sel)
    2'b00: begin
        csn_mul = {2'b11, csn};
    end
    2'b01: begin
        csn_mul = {1'b1, csn, 1'b1};
    end
    2'b10: begin
        csn_mul = {csn, 2'b11};
    end
    2'b11: begin
        csn_mul = {3'b111};
    end
    endcase;
end


always @(posedge clk) begin
    if((mosi_stb & ready) | (mosi_stb & miso_stb)) begin
        s3_recv_data <= `DLY $random;
    end
end

always @(posedge wr_edge) begin
    if(s3_mode) begin
        if((data_count>=WRITE_BITS) & (data_count<SPI_WIDTH)) begin
            sdio_s_in     <= `DLY s3_recv_data[READ_BITS-1];
            s3_recv_data <= `DLY {s3_recv_data[READ_BITS-2:0], s3_recv_data[READ_BITS-1]};
        end else begin
        end
    end else begin        
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
