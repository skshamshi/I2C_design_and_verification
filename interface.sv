interface memorysubsystem (input logic clk,rst);
parameter DATAWIDTH=8;
parameter ADDRWIDTH=7;

logic mastersda;
logic slavesda;
logic scl;
logic enable;
logic [DATAWIDTH-1:0]data_in;
logic [ADDRWIDTH-1:0]addr;
logic ack;
logic write;
logic read;

modport i2c_master(
output mastersda,
input clk,
input rst,
output scl,
input enable,
input data_in,
input addr,
input ack,
input write,
input read
);

modport mc_slave (
input slavesda,
input clk,
input rst,
input scl,
input data_in,
output ack
);
endinterface
