`timescale 1ns / 1ps

module Testbench_final;
  
    // CLOCK GENERATION (System Clock)
    reg sys_clk = 0;
    always #5 sys_clk = ~sys_clk;   // 100 MHz clock (10 ns period)
  
    // Inputs (driven)
    reg reset;
    reg enable_prng;
    reg enable_rosc;

    reg [2:0] stage_sel1;
    reg [2:0] stage_sel2;
    reg [2:0] stage_sel3;
    reg [2:0] freq_sel;

    integer f, a, b, c;

    // Outputs / wires=
    wire [3:0] out;
    wire sample_clk;
  
    // Instantiate Frequency Selector
    Freqsel_final FS (
        .sys_clk(sys_clk),
        .reset(reset),
        .freq_sel(freq_sel),
        .sample_clk(sample_clk)
    );

  
    // Instantiate TRNG
    trng_final uut (
        .out(out),
        .reset(reset),
        .enable_prng(enable_prng),
        .enable_rosc(enable_rosc),
        .stage_sel1(stage_sel1),
        .stage_sel2(stage_sel2),
        .stage_sel3(stage_sel3),
        .sample_clk(sample_clk)
    );
    
   
    // Waveform Dump
    initial begin
        $dumpfile("trng_final.vcd");
        $dumpvars(0, Testbench_final);
    end


    // Main Test Sequence
    initial begin
        // Initial reset
        reset       = 1;
        enable_prng = 0;
        enable_rosc = 0;

        stage_sel1 = 3'b000;
        stage_sel2 = 3'b010;
        stage_sel3 = 3'b100;

        freq_sel   = 3'b000;

        #200;
        reset = 0;

        #100;
        enable_rosc = 1;  // Start ROs
        enable_prng = 1;  // Start TRNG
        
        

        for (f = 0; f < 5; f = f + 1) begin
        freq_sel = f;

        for (a = 0; a < 5; a = a + 1) begin
          stage_sel3 = a;

          for (b = 0; b < 5; b = b + 1) begin
            stage_sel2 = b;

            for (c = 0; c < 5; c = c + 1) begin
                stage_sel1 = c;

                #300;   // allow TRNG to generate several outputs
            end
        end
    end
end



  
        // Sweep Sampling Frequencies
    
        $display("\n========== Frequency Sweep ==========\n");

        freq_sel = 3'b000;  #300;  // Fastest sampling
        freq_sel = 3'b001;  #600;
        freq_sel = 3'b010;  #1200;
        freq_sel = 3'b011;  #2400;
        freq_sel = 3'b100;  #4800;  // Slowest sampling
     

        // Sweep Stage Selections for ROs (5x5x5)
        $display("\n========== Stage Sweep ==========\n");

        $display("\n========== Test Completed ==========\n");
        
// Combined Sweep: frequencies × RO stages

$display("\n========== Full Sweep: Frequency × Stage ==========\n");


        #5000;
        $finish;
    end


    // Monitor TRNG Output
    always @(posedge sample_clk) begin
        $display("Time=%0t | FreqSel=%0d | ST1=%0d ST2=%0d ST3=%0d | TRNG=%0d",
                 $time, freq_sel, stage_sel1, stage_sel2, stage_sel3, out);
    end

endmodule
