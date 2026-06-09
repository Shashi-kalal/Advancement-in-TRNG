`timescale 1ns / 1ps

module Freqsel_final (
    input  wire sys_clk,        // master clock (e.g., 50-200 MHz)
    input  wire reset,
    input  wire [2:0] freq_sel, // 5 frequency options (0-4)
    output reg  sample_clk = 0
);

    // Frequency divider count values (change as needed)
    reg [15:0] divider_value;
    reg [15:0] counter = 0;

    // Select different output sampling frequencies
    always @(*) begin
        case(freq_sel)
            3'b000: divider_value = 16'd10;   // Fastest
            3'b001: divider_value = 16'd30;
            3'b010: divider_value = 16'd80;
            3'b011: divider_value = 16'd150;
            3'b100: divider_value = 16'd300;  // Slowest
            default: divider_value = 16'd50;
        endcase
    end

    // Divide the system clock frequency
    always @(posedge sys_clk or posedge reset) begin
        if (reset) begin
            sample_clk <= 0;
            counter    <= 0;
        end else begin
            if (counter >= divider_value) begin
                sample_clk <= ~sample_clk;
                counter    <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
