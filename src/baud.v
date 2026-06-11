module baud #(parameter CPOL = 0)(
    input clk,
    input rst,
    output reg SCLK
);
    reg [13:0] counter;
    always @(posedge clk) begin
        if(rst) begin
            counter <= 0;
            SCLK <= CPOL;
        end
        else if(counter == 10) begin
            SCLK <= ~SCLK;
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
        end
    end
endmodule
