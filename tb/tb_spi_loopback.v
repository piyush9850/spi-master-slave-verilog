module SPI_LOOPBACK_TB;
    reg clk;
    reg rst;
    reg enable;
    reg [7:0] master_data, slave_data;
 
    wire MOSI, MISO, CS, SCLK;
    wire [7:0] master_out, slave_out;
    wire master_done, slave_done;
 
    parameter CPOL = 0;
    parameter CPHA = 0;
 
    SPI_master #(.CPOL(CPOL), .CPHA(CPHA)) one (
        .clk(clk), .rst(rst), .enable(enable),
        .MISO(MISO), .data_in(master_data),
        .MOSI(MOSI), .CS(CS),
        .data_out(master_out), .done(master_done), .SCLK(SCLK)
    );
 
    SPI_slave #(.CPOL(CPOL), .CPHA(CPHA)) two (
        .clk(clk), .rst(rst),
        .SCLK(SCLK), .MOSI(MOSI), .CS(CS),
        .data_in(slave_data),
        .MISO(MISO), .data_out(slave_out), .done(slave_done)
    );
 
    always #5 clk = ~clk;
 
    initial begin
        master_data = 8'hA5;
        slave_data  = 8'hF1;
 
        $dumpfile("SPI_sim.vcd");
        $dumpvars(0, SPI_LOOPBACK_TB);
 
        $monitor("Time=%0t | master_out=%b (%h) | slave_out=%b (%h) | master_done=%b | slave_done=%b",
                 $time, master_out, master_out, slave_out, slave_out, master_done, slave_done);
 
        clk    = 0;
        rst    = 1;
        enable = 0;
        #20;
        rst = 0;
        #10;
        enable = 1;
        #20;
        enable = 0;
        #5000;
        $finish;
    end
endmodule
