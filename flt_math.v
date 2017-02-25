// Author: contact@simpleasic.com
// License: MIT License
//
// Some of the functions were modified from "Verilog Transcendental Functions for Numerical Testbenches"
// by Mark G. Arnold, et al.  The International HDL Conference & Exibition, 2001
// The original link to the paper seemed to have disappeared.
// Here's a copy of the presentation slides:
// http://www.slideserve.com/pearly/verilog-transcendental-functions-for-numerical-testbenches
//
// Modifications:
// - improve precision slightly
// - modernize function declaration with newer verilog constructs
// - use "**" for exponential function
// - add log2, log10, exp, fcmp*, etc function

// Absolute value of floating point
function real fabs(input real x);
  fabs = (x<0) ? -x : x;
endfunction

// Compare 2 floating point numbers, 
// return 1 if the two are close within an error margin_factor
// Default margin_factor = 0.001 = 0.1% of input x
// x should be the expected value
// If x is smaller than MIN_X, the error margin is fixed at MIN_X*margin_factor
function fcmp(input real x, input real y, input real margin_factor = 0.001);
  parameter MIN_X = 0.0000001;
  if (fabs(x)<MIN_X)
    fcmp = (fabs(x-y) < MIN_X*margin_factor) ? 1 : 0;
  else
    fcmp = (fabs(x-y) < fabs(x)*margin_factor) ? 1 : 0;
endfunction

// Compare 2 floating point numbers
// return 1 if the two are close within an absolute error margin.
function fcmp2(input real x, input real y, input real margin);
  fcmp2 = (fabs(x-y) < margin) ? 1 : 0;
endfunction


function real rootof2(input integer n);
  rootof2 = 2.0**(2.0**n);
endfunction

function real exp(input real x);
  exp = 2.71828182845905**x;
endfunction

function real log(input real x);
  real re,log2;
  integer i;
  begin
    if (x <= 0.0)
      begin
        $display("ERROR: log illegal argument:",x);
        $stop;
        log = 0;
      end
    else
      begin  
        if (x<1.0)
          re = 1.0/x;
        else
          re = x;
        log2 = 0.0;
        for (i=7; i>=-23; i=i-1) 
          begin
            if (re > rootof2(i))
              begin
                re = re/rootof2(i);
                log2 = 2.0*log2 + 1.0;
              end
            else
              log2 = log2*2;
          end
        if (x < 1.0)
          log = -log2/12102203.16;
        else
          log = log2/12102203.16;
      end
    end
endfunction 

function real log2(input real x);
  log2 = log(x) / 0.693147180559945;
endfunction

function real log10(input real x);
  log10 = log(x) / 2.30258509299405;
endfunction


function real sin(input real x);
  real x1,y,y2,y3,y5,y7,sum,sign;
  begin
    sign = 1.0;
    x1 = x;
    if (x1<0)
      begin
        x1 = -x1;
        sign = -1.0;
      end
    while (x1 > 3.14159265/2.0)
      begin
        x1 = x1 - 3.14159265;
        sign = -1.0*sign;
      end  
    y = x1*2/3.14159265;
    y2 = y*y;
    y3 = y*y2;
    y5 = y3*y2;
    y7 = y5*y2;
    sum = 1.570794*y - 0.645962*y3 +
           0.079692*y5 - 0.004681712*y7;
    sin = sign*sum;
  end
endfunction

function real cos(input real x);
  cos = sin(x + 3.14159265/2.0);
endfunction

function real tan(input real x);
  tan = sin(x)/cos(x);
endfunction

