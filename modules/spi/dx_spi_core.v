`timescale 1ns / 100ps
`define DLY #1

// from mosi_stb to miso_stb latency is (spi_width+1)*(SCLK_DIV+1)*2*(clk_period)
// minimun efficient gap time between two mosi_stb is
//     (spi_width+1)*(SCLK_DIV+1)*2*(clk_period) + clk_period
// cpol, cpha, sclk_div, mosi_data_i
//     these four config and data signals are stored when mosi_stb set.
// miso_data_o is valid from miso_stb to the next data transfer.
// if spi_width < DATA_WIDTH, this spi core will send high (spi_width) bits of mosi_data
//     and set low (spi_width) bits of miso_data.

module dx_spi_core
#(
	parameter DATA_WIDTH = 32,
	parameter DATA_COUNT_WIDTH = 8,  // 8 for a DATA_WIDTH and SPI_WIDTH range in (1,255).
	// (2^DATA_COUNT_WIDTH)-1 >= DATA_WIDTH
	parameter SCLK_COUNT_WIDTH = 16
	// (2^SCLK_COUTN_WIDTH)-1 >= sclk_div
)
(
	input wire clk,
	input wire rst,

	// dx_spi config input.
	input wire [DATA_COUNT_WIDTH-1:0] spi_width_i,
	// spi actual send bits, spi_width <= DATA_WIDTH.
	input wire cpol_i, // idle state of sclk
	input wire cpha_i,
	// CPHA = 0  read on first  edge and write on second edge.
	// CPHA = 1  read on second edge and write on first  edge.
	input wire [SCLK_COUNT_WIDTH-1:0] sclk_div_i,
	// sclk_div >= 1

	// data to/from fpga side.
	input wire mosi_stb,
	input wire [DATA_WIDTH-1:0] mosi_data_i,
	output reg miso_stb,
	output wire [DATA_WIDTH-1:0] miso_data_o,

	// dx_spi state.
	output wire ready_o,
	output reg [2:0] state_o,
	output wire [DATA_COUNT_WIDTH-1:0] data_count_o,
	output reg wr_edge,
	output reg rd_edge,

	// physical interface.
	output reg sclk,
	output reg mosi,
	input wire miso,
	output reg csn
);

reg [SCLK_COUNT_WIDTH-1:0] sclk_count;
wire sclk_count_begin;
wire sclk_count_done;
// sclk count when spi core is not ready.(is running)
always @(posedge clk) begin
	if(rst | (mosi_stb & ready) | (mosi_stb & miso_stb)) begin
		sclk_count <= `DLY {SCLK_COUNT_WIDTH{1'b0}};
	end else if(~ready) begin
		if(sclk_count_done) begin
			sclk_count <= `DLY {SCLK_COUNT_WIDTH{1'b0}};
		end
		else begin
			sclk_count <= `DLY sclk_count + 1'b1;
		end
	end else begin
		sclk_count <= `DLY {SCLK_COUNT_WIDTH{1'b0}};
	end
end

assign sclk_count_begin = (sclk_count == {SCLK_COUNT_WIDTH{1'b0}});
assign sclk_count_done  = (sclk_count == sclk_div);

wire   data_count_done;
assign data_count_done  = (data_count == spi_width);


localparam ST_IDLE = 0;
// when there is mosi_stb,
// store config spi_width, cpol, cpha, sclk_div, and mosi_data.
// pull down ready and enter ST_CONFIG.
// set other signal to default.
localparam ST_CONFIG = 1;
// set sclk polarity according to cpol,
// clear miso_data.
localparam ST_PRE = 2;
// half period between csn dropping edge and sclk's most first edge.
localparam ST_EDGE_A = 3;
// half period after first  edge.
// or to say the scmosi_stblk is at inverse of CPOL.
localparam ST_EDGE_B = 4;
// half period after second edge.
// or to say the sclk is the same as CPOL.
localparam ST_POST = 5;
// half period between sclk's last second edge and csn rising edge.


reg [2:0] state;
reg ready;
reg [DATA_COUNT_WIDTH-1:0] spi_width;
reg cpol;
reg cpha;
reg [SCLK_COUNT_WIDTH-1:0] sclk_div;
reg [DATA_COUNT_WIDTH-1:0] data_count;
reg [DATA_WIDTH-1:0] mosi_data;
reg [DATA_WIDTH-1:0] miso_data;
// state, ready
// spi_width, cpol, cpha, sclk_div, mosi_data
// data_count, wr_edge, rd_edge
// csn, sclk
// mosi, mosi_data
// miso_data, miso_stb
always @(posedge clk) begin
	if(rst) begin
		state <= `DLY ST_IDLE;
		ready <= `DLY 1'b1;
		data_count <= `DLY {DATA_COUNT_WIDTH{1'b0}};
		wr_edge    <= 1'b0;
		rd_edge    <= 1'b0;
		csn  <= `DLY 1'b1;
		sclk <= cpol;
		mosi <= `DLY 1'bz;
		miso_data <= `DLY {DATA_WIDTH{1'b0}};
		miso_stb  <= `DLY 1'b0;
	end else begin
		case(state)
		ST_IDLE: begin
			data_count <= `DLY {DATA_COUNT_WIDTH{1'b0}};
			wr_edge    <= 1'b0;
			rd_edge    <= 1'b0;
			csn  <= `DLY 1'b1;
			sclk <= cpol;
			mosi <= `DLY 1'bz;
			miso_stb <= `DLY 1'b0;
			if(mosi_stb) begin
				state <= `DLY ST_CONFIG;
				ready <= `DLY 1'b0;
				spi_width <= `DLY spi_width_i;
				cpol      <= `DLY cpol_i;
				cpha      <= `DLY cpha_i;
				sclk_div  <= `DLY sclk_div_i;
				mosi_data <= `DLY mosi_data_i;
			end else begin
				ready <= `DLY 1'b1;
			end
		end
		ST_CONFIG: begin
			if(sclk_count_done) begin
				state <= `DLY ST_PRE;
			end else begin
				sclk <= cpol;
				miso_data <= `DLY {DATA_WIDTH{1'b0}};
			end
		end
		ST_PRE: begin
			if(sclk_count_done) begin
				state <= `DLY ST_EDGE_A;
			end
			if(sclk_count_begin) begin
				csn <= `DLY 1'b0;
			end
			if(~cpha) begin // CPHA = 0
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
					data_count <= `DLY data_count + 1'b1;
					wr_edge    <= 1'b1;
					mosi      <= `DLY mosi_data[DATA_WIDTH-1];
					mosi_data <= `DLY {mosi_data[DATA_WIDTH-2:0], 1'b0};
				end else begin
				end
			end else begin  // CPHA = 1
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
				end else begin
				end
			end
		end
		ST_EDGE_A: begin
			if(sclk_count_done) begin
				if(data_count_done) begin
					state <= `DLY ST_POST;
				end else begin
					state <= `DLY ST_EDGE_B;
				end
			end
			sclk <= ~cpol;
			if(~cpha) begin // CPHA = 0
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
    				wr_edge    <= 1'b0;
					rd_edge    <= 1'b1;
					miso_data <= `DLY {miso_data[DATA_WIDTH-2:0], miso};
				end else begin
				end
			end else begin  // CPHA = 1
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
					data_count <= `DLY data_count + 1'b1;
					wr_edge    <= 1'b1;
					rd_edge    <= 1'b0;
					mosi      <= `DLY mosi_data[DATA_WIDTH-1];
					mosi_data <= `DLY {mosi_data[DATA_WIDTH-2:0], 1'b0};
				end else begin
				end
			end
		end
		ST_EDGE_B: begin
			if(sclk_count_done) begin
				state <= `DLY ST_EDGE_A;
			end
			sclk <= cpol;
			if(~cpha) begin // CPHA = 0
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
					data_count <= `DLY data_count + 1'b1;
					wr_edge    <= 1'b1;
					rd_edge    <= 1'b0;
					mosi      <= `DLY mosi_data[DATA_WIDTH-1];
					mosi_data <= `DLY {mosi_data[DATA_WIDTH-2:0], 1'b0};
				end else begin
				end
			end else begin  // CPHA = 1
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
    				wr_edge    <= 1'b0;
					rd_edge    <= 1'b1;
					miso_data <= `DLY {miso_data[DATA_WIDTH-2:0], miso};
				end else begin
				end
			end
		end
		ST_POST: begin
			if(sclk_count_done) begin
				state <= `DLY ST_IDLE;
				miso_stb <= `DLY 1'b1;
			end
			sclk <= cpol;
			if(~cpha) begin // CPHA = 0
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
					data_count <= `DLY {DATA_COUNT_WIDTH{1'b0}};
					rd_edge    <= 1'b0;
					mosi <= `DLY 1'bz;
				end else begin
				end
			end else begin  // CPHA = 1
				if(sclk_count_done) begin
				end else if(sclk_count_begin) begin
				    wr_edge    <= 1'b0;
					rd_edge    <= 1'b1;
					miso_data <= `DLY {miso_data[DATA_WIDTH-2:0], miso};
				end else begin
				end
			end
		end
		default: begin
			state <= `DLY ST_IDLE;
		end
		endcase
	end
end

assign miso_data_o = miso_data;
assign ready_o = ready;
assign data_count_o = data_count;

always @(posedge clk) begin
	state_o <= `DLY state;
end

endmodule
