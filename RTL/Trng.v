`timescale 1ns / 1ps

module trng_final(
    output reg [3:0] out,
    input reset,
    input enable_prng,
    input enable_rosc,
    input sample_clk,
    input [2:0] stage_sel1,
    input [2:0] stage_sel2,
    input [2:0] stage_sel3
);
    
    reg meta1, meta2;
    wire ro1, ro2, ro3;
    wire random_bit;
    wire clk_internal;

    // Two independent ring oscillators
    RingOsc_final RO1(
        .enable(enable_rosc),
        .stage_sel(stage_sel1),
        .osc_out(ro1)
    );

    RingOsc_final RO2(
        .enable(enable_rosc),
        .stage_sel(stage_sel2),
        .osc_out(ro2)
    );
    
    RingOsc_final RO3(
        .enable(enable_rosc),
        .stage_sel(stage_sel3),
        .osc_out(ro3)
    );

    // XOR for entropy
    

     always @(posedge ro1) begin
      meta1 <= ro2;
      meta2 <= meta1;
     end

     assign random_bit = meta2 ^ ro3;
     wire whitened_bit = random_bit ^ out[0] ^ out[1];

    // 3-bit randomness shift register
    always @(posedge sample_clk or posedge reset) begin
    if (reset || !enable_prng)
        out <= 4'b0000;
    else if (random_bit !== 1'bx)
        out <= {out[2:0], whitened_bit};
end

endmodule
