`timescale 1ns / 100ps
`define DLY #1

// dx_spi_m4s3, convert master 4 wire spi model to slave 3 wire model.
// only convert mosi to sdio, convert sdio to miso_m for specific csn signal selected.

module dx_spi_m4s3 #(
    parameter CSN_NUM = 8,
    parameter S3_EN = 8'b00001111,
    // correspond bit set to 1, if the slave is in 3-wire mode.
    parameter CPOL = 8'b00000000,
    parameter CPHA = 8'b00000001,
    parameter READ = 8'b00000011, // first bit when it is read.
    parameter WRITE_BITS = 16,
    // in 3-wire mode write these bits then read/write.
    parameter DATA_COUNT_WIDTH = 8
) (
    input  wire sclk,
    input  wire mosi_m,
    output wire miso_m,
    input  wire [CSN_NUM-1:0] csn, // guarantee there's at most one slave selected.

    input  wire miso_s,
    inout  wire sdio_s,
    
    output wire s3_mode  // some 3-wire slave selected.
);

// TODO: cpol, cpha, spi_width, read/write, write bit num.

wire [CSN_NUM-1:0] s3_csn_sel;  // which 3-wire slave selected.
assign s3_csn_sel = ~csn & S3_EN;
assign s3_mode = | s3_csn_sel;
wire cpol;
wire cpha;
wire read;
assign cpol = | (CPOL & s3_csn_sel);
assign cpha = | (CPHA & s3_csn_sel);
assign read = | (READ & s3_csn_sel);
wire rise_edge_read = ~(cpol ^ cpha);

reg [DATA_COUNT_WIDTH-1:0] data_count = {DATA_COUNT_WIDTH{1'b0}};
reg sdio_en = 1'b0;  // sdio as input.
reg rw_mode;  // this data transmit is read(1) / write(0).

wire sel_n;  // some slave selected.
assign sel_n = & csn;

always @(posedge sclk or posedge sel_n) begin
    if(rise_edge_read) begin
        if(sel_n) begin
            data_count <= `DLY {DATA_COUNT_WIDTH{1'b0}};
            rw_mode    <= `DLY 1'b0;
        end else begin
            data_count <= `DLY data_count + 1'b1;
            if(data_count == {DATA_COUNT_WIDTH{1'b0}}) begin
                rw_mode <= `DLY ~(mosi_m ^ read);
            end
        end
    end else begin
        if(sel_n) begin
            sdio_en <= `DLY 1'b0;
        end else begin
            if(data_count == WRITE_BITS) begin
                sdio_en <= `DLY rw_mode & s3_mode;
            end
        end
    end
end

always @(negedge sclk or posedge sel_n) begin
    if(rise_edge_read) begin
        if(sel_n) begin
            sdio_en <= `DLY 1'b0;
        end else begin
            if(data_count == WRITE_BITS) begin
                sdio_en <= `DLY rw_mode & s3_mode;
            end
        end
    end else begin
        if(sel_n) begin
            data_count <= `DLY {DATA_COUNT_WIDTH{1'b0}};
            rw_mode    <= `DLY 1'b0;
        end else begin
            data_count <= `DLY data_count + 1'b1;
            if(data_count == {DATA_COUNT_WIDTH{1'b0}}) begin
                rw_mode <= `DLY ~(mosi_m ^ read);
            end
        end
    end
end

wire miso_sdio;
dx_iobuf #(
    .DATA_WIDTH(1)
) iobuf_spi_sdio (
    .dio_i(mosi_m),
    .dio_o(miso_sdio),
    .dio_t(sdio_en),
    .dio_p(sdio_s)
);

assign miso_m = s3_mode ? miso_sdio : miso_s;



endmodule
