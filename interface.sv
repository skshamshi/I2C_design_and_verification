interface memorysubsystem (input logic clk,rst);
logic mastersda;
logic slavesda;
logic scl;
logic enable;


modport i2c_master(
output mastersda,
input clk,
input rst,
output scl,
input enable
);

modport mc_slave (
input slavesda,
input clk,
input rst,
input scl
);
endinterface
