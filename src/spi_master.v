module SPI_master #(
    parameter CPOL = 0,
    parameter CPHA = 0
)(
    input clk,
    input rst,
    input enable,
    input MISO,
    input [7:0] data_in,
    output reg MOSI,
    output reg CS,
    output reg [7:0] data_out,
    output reg done,
    output wire SCLK
);
    baud #(.CPOL(CPOL)) one (.clk(clk), .rst(rst), .SCLK(SCLK));
 
    parameter IDLE = 2'b00, TRANSFER = 2'b01, DONE = 2'b10;
    reg [1:0] S;
    reg [2:0] bit_counter;
    reg SCLK_d;
 
   
    wire rising  = SCLK && ~SCLK_d;
    wire falling = ~SCLK && SCLK_d;
 
   
    wire sample_edge = (CPOL == CPHA) ? rising  : falling;
    wire drive_edge  = (CPOL != CPHA) ? falling : rising;
 
    always @(posedge clk) begin
        SCLK_d <= SCLK;
        done   <= 0;
 
        if(rst) begin
            S           <= IDLE;
            CS          <= 1;
            bit_counter <= 0;
            data_out    <= 0;
            MOSI        <= 0;
            done        <= 0;
        end
        else begin
            case(S)
                IDLE: begin
                    CS <= 1;
                    if(enable) begin
                        S           <= TRANSFER;
                        bit_counter <= 0;
                        
                        MOSI <= data_in[7];
                    end
                end
 
                TRANSFER: begin
                    CS <= 0;
 
                   
                    if(drive_edge) begin
                        MOSI <= data_in[7 - (bit_counter + 1)];
                    end
 
                    
                    if(sample_edge) begin
                        data_out    <= {data_out[6:0], MISO};
                        bit_counter <= bit_counter + 1;
                        if(bit_counter == 7)
                            S <= DONE;
                    end
                end
 
                DONE: begin
                    CS   <= 1;
                    done <= 1;
                    S    <= IDLE;
                    bit_counter <= 0;
                end
            endcase
        end
    end
endmodule
