// Author: contact@simpleasic.com
// License: MIT License

// Floating point (real) to fixed-point conversion
// The output is an N-bit signed integer with N-M fraction bits.
// The output is in 2's complement format.
// Maximum supported N is 64.
// e.g. N=16, M=1: x.xxx..xx: represents numbers in (-1,1), LSB = 2**(-15)
//      N=16, M=2: xx.xxx..x: represents numbers in (-2,2), LSB = 2**(-14)
function signed [63:0] flt2fix(input real flt, input int N, input int M=1);
begin
  real out;
  reg signed [63:0] max;
  reg signed [63:0] min;
  if (N>64) begin
    $display("ERROR: flt2fix supports up to N = 64");
    $finish;
  end
  if (M<1 || M>N) begin
    $display("ERROR: Configuration error for flt2fix, M should be between 1 and N.");
    $finish;
  end

  max = (64'd1 << (N-1)) - 1; 
  min = -((64'd1 << (N-1)));
  //out = flt * (64'd1 << (N-M)) + 0.5;  // scale up
  out = flt * (64'd1 << (N-M));

  if (out > max)
    out = max;
  else if (out < min)
    out = min;

  // Convert to fixed point, caller is responsible for truncating MSBs
  flt2fix = out;
end
endfunction


// Fixed-point to Floating point (real) conversion.
// Maximum supported N is 64.
function real fix2flt(input signed [63:0] fix, input int N, input int M=1);
begin
  real out;

  if (N>64) begin
    $display("ERROR: flt2fix supports up to N = 64");
    $finish;
  end
  if (M<1 || M>N) begin
    $display("ERROR: Configuration error for flt2fix, M should be between 1 and N.");
    $finish;
  end

  fix = (fix <<< (64-N)) >>>(64-N);

  out = fix;  // convert to real
  fix2flt = out / (64'd1 << (N-M));

end
endfunction


// Generate a real random number within a specified range
// Using the same function API as $urandom_range
function real frandom(input real maxval=1, input real minval=-1);
reg signed [63:0] long_rand;
begin
  long_rand={$urandom,$urandom};
  frandom = fix2flt(long_rand, 64);
  frandom = frandom/2*(maxval-minval) + (maxval+minval)/2;
end
endfunction
