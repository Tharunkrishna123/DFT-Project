
module DFT1_tb;
  reg refclk, clk2, reset;
  reg [4:0] data_in;
  wire [4:0] data_out;

  DFT1 dut(.refclk(refclk), .reset(reset), .clk2(clk2), .data_in(data_in), .data_out(data_out));

  // Clock generation
  initial begin
    refclk = 1;
    forever #5 refclk = ~refclk;  // 10 time units
  end

  initial begin
    clk2 = 1;
    forever #6 clk2 = ~clk2;      // 12 time units
  end

  // Stimulus
  initial begin
    reset = 1'b1;
    #10 reset = 1'b0;

    #5 data_in = 5'b00001;
    #10 data_in = 5'b00100;
    #10 data_in = 5'b00011;
    #10 data_in = 5'b00111;
    #10 data_in = 5'b11111;
    #40 $finish;
  end

  // Monitor changes
  initial $monitor("Time = %0t | data_in = %b | data_out = %b", $time, data_in, data_out);

  // Dump VCD for waveform
  initial begin
    $dumpfile("DFT1_tb.vcd");
    $dumpvars(0, DFT1_tb);
  end
endmodule
