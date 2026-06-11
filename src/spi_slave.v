module SPI_slave #(
    parameter CPOL = 0,
    parameter CPHA = 0
)(
    input clk,
    input rst,
    input SCLK,
    input MOSI,
    input CS,
    input [7:0] data_in,
    output reg MISO,
    output reg [7:0] data_out,
    output reg done
);
    parameter IDLE = 1'b0, TRANSFER = 1'b1;
    reg S;
    reg [2:0] bit_counter;
    reg [7:0] TX_reg;
    reg SCLK_d;
 
    wire rising  = SCLK && ~SCLK_d;
    wire falling = ~SCLK && SCLK_d;
 
    wire sample_edge = (CPOL == CPHA) ? rising  : falling;
    wire drive_edge  = (CPOL == CPHA) ? falling : rising;
 
    always @(posedge clk) begin
        done   <= 0;
        SCLK_d <= SCLK;
 
        if(rst) begin
            S           <= IDLE;
            bit_counter <= 0;
            data_out    <= 0;
            MISO        <= 0;
            TX_reg      <= 0;
        end
        else begin
            case(S)
                IDLE: begin
                    bit_counter <= 0;
                    if(!CS) begin
                        S      <= TRANSFER;
                        TX_reg <= data_in;
                        
                        MISO   <= data_in[7];
                    end
                end
 
                TRANSFER: begin
                    if(CS) begin
                        S <= IDLE;
                    end
                    else begin
                        // Drive MISO on drive_edge
                        if(drive_edge) begin
                            TX_reg <= {TX_reg[6:0], 1'b0};
                            MISO   <= TX_reg[6]; // next bit
                        end
 
                        // Sample MOSI on sample_edge
                        if(sample_edge) begin
                            data_out    <= {data_out[6:0], MOSI};
                            bit_counter <= bit_counter + 1;
                            if(bit_counter == 7) begin
                                done <= 1;
                                S    <= IDLE;
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule
