# verilog_float
Collection of verilog functions for building a floating-point based testbench.

For more details, see source code comments and  
http://simpleasic.com/floating-point-based-testbenches/

This has been tested with Icarus Verilog version devel s20150603-430-gc706c5d
(https://github.com/steveicarus/iverilog)

To run, use
iverilog -g2012 math_test.v

To run with modified parameters,
iverilog -g2012 -D SEED=3 -D WDAT=10 -D WACC=15

