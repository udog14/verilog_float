// This is an example of using flt_math.v and flt_conv.v to build
// tests in floating point domain.
// Author: contact@simpleasic.com
// License: MIT License

//--------------------------------------------------------------
// RTL bitwidth configuration
// Change these to see variation on the output errors.
//--------------------------------------------------------------
`ifndef WDAT
  `define WDAT 16
`endif

`ifndef WACC
  `define WACC 24
`endif

`ifndef SEED
  `define SEED 10
`endif

//--------------------------------------------------------------
// Testbench
//--------------------------------------------------------------
module tb;

`include "flt_math.v"
`include "flt_conv.v"

reg  clk;
reg  reset_n;
reg  [`WDAT-1:0] x;
reg  [`WDAT-1:0] y;
wire [`WACC-1:0] out;
real  x_real;
real  y_real;
real  out_real;
real  exp_real;
real  signal_pwr;
real  noise_pwr;
int   i;


initial begin
  i = `SEED;
  i = $urandom(i);  // seed the random function
  reset_n = 0;
  exp_real = 0;
  signal_pwr = 0;
  noise_pwr = 0;
  x_real = 0;
  y_real = 0;
  x = flt2fix(x_real, `WDAT);
  y = flt2fix(y_real, `WDAT);

  @(posedge clk) #1 reset_n = 1;

  for (i=0; i<20; i=i+1) begin
    @(posedge clk) #1;
    //--------------------------------------
    // Check output (from previous cycle)
    //--------------------------------------
    exp_real   = exp_real + x_real * y_real;
    out_real   = fix2flt(out, `WACC);
    signal_pwr = signal_pwr + exp_real**2;
    noise_pwr  = noise_pwr  + (exp_real-out_real)**2;

    //$display("in: %8h, %8h -> out: %8h", x, y, out);
    $display("in: %8.5f, %8.5f -> out: %8.5f, exp: %8.5f", x_real, y_real, out_real, exp_real);
    if (!fcmp(exp_real, out_real, 0.01))
      $display("WARNING: output sample diviates more than 1%% from expected.");

    //--------------------------------------
    // Drive new inputs
    //--------------------------------------
    x_real = frandom(1, -1);
    y_real = frandom(0.2, -0.1);
    x = flt2fix(x_real, `WDAT);
    y = flt2fix(y_real, `WDAT);
  end

  $display(">> SNR = %5.2f dB", 10*log10(signal_pwr/noise_pwr));

  $finish;
end


initial begin
  clk = 0;
  forever #10 clk = ~clk;
end


// Since output is verified in real (a 2-state signal), it's a good idea
// to check that output bits are all valid.
initial begin
  wait (reset_n == 1);

  // if any of the bits is x, the xor reduction will produce 1'bx
  forever begin
    @(out) if (^out === 1'bx)
      $display("ERROR: Detect unknown bit(s) on the output, %b.", out);
  end
end


// Device under test
mac #(`WDAT, `WACC) mac (
  .clk(clk),
  .reset_n(reset_n),
  .x(x),
  .y(y),
  .out(out)
);

endmodule


//--------------------------------------------------------------
// Fixed point multiply-accumulate, used as a DUT example
//--------------------------------------------------------------
module mac #(
  parameter WDAT = 16,      // bitwidth of data
  parameter WACC = 32       // bitwidth of accumulator & output
)(
  input            clk,
  input            reset_n,
  input signed [WDAT-1:0] x,
  input signed [WDAT-1:0] y,
  output reg signed [WACC-1:0] out
);

wire signed [2*WDAT-2:0] product = x*y;

always @(posedge clk)
  if (!reset_n)
    out <= 0;
  else
    out <= out + product[2*WDAT-2 -:WACC];

endmodule

