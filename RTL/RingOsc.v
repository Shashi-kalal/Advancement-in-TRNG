`timescale 1ns / 1ps

module RingOsc_final (
    input        enable,
    input  [2:0] stage_sel,
    output reg   osc_out
);

    // Internal wires for inverter chain
    wire [10:0] n;
    reg  fb;

    // ---- Inverter chain (structural style) ----
    inv u0  (.in(osc_out), .out(n[0]));
    inv u1  (.in(n[0]),    .out(n[1]));
    inv u2  (.in(n[1]),    .out(n[2]));
    inv u3  (.in(n[2]),    .out(n[3]));
    inv u4  (.in(n[3]),    .out(n[4]));
    inv u5  (.in(n[4]),    .out(n[5]));
    inv u6  (.in(n[5]),    .out(n[6]));
    inv u7  (.in(n[6]),    .out(n[7]));
    inv u8  (.in(n[7]),    .out(n[8]));
    inv u9  (.in(n[8]),    .out(n[9]));
    inv u10 (.in(n[9]),    .out(n[10]));

    // ---- Feedback MUX ----
    always @(*) begin
        case(stage_sel)
            3'b000: fb = n[2];
            3'b001: fb = n[4];
            3'b010: fb = n[6];
            3'b011: fb = n[8];
            3'b100: fb = n[10];
            default: fb = n[2];
        endcase
    end

    // ---- Oscillation control with delay ----
    always begin
        if (enable) begin
            #(100 * (stage_sel + 1));
            osc_out = fb;
        end else begin
            osc_out = 1'b0;
            #10;
        end
    end

endmodule
