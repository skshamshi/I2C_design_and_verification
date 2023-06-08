module FunctionalUnit(data_out, clk, rst, data_in, S, MSBIn, LSBIn);
parameter N = 8;
output logic[N-1:0] data_out;
input logic clk;
input logic rst;
input logic [N-1:0] data_in;
input logic [$clog2(N)-1:0] S;
input logic MSBIn;
input logic LSBIn;

logic [N-1:0]Y;
logic [7:0] Temp [N-1:0];

assign Temp[0] = {1'b0, data_out[1], data_out[N-1], data_out[1], LSBIn, data_out[1], data_in[0], data_out[0]};
assign Temp[N-1] = {data_out[N-2], data_out[N-1], data_out[N-2], data_out[0], data_out[N-2], MSBIn, data_in[N-1], data_out[N-1]};

genvar i;
generate
	for(i = 1; i < N-1; i++)
	begin
		assign Temp[i] = {data_out[i-1],data_out[i+1],data_out[i-1],data_out[i+1],data_out[i-1],data_out[i+1],data_in[i],data_out[i]};
	end
endgenerate
	
Mux DUT1 [N-1:0](Y, Temp, S);
DFF DUT2 [N-1:0] (data_out, clk, rst, Y);

endmodule

module DFF(data_out, clk, rst, data_in);
output logic data_out;
input logic clk, rst, data_in;

always_ff@(posedge clk)
	begin
		if(rst)
			data_out <= 1'b0;
		else
		 	data_out <= data_in;		
	end
endmodule 

module Mux(Y, V, S);
parameter N = 8;
output logic Y;
input logic [N-1:0] V;
input logic [$clog2(N)-1 : 0] S;

assign Y = V[S];

endmodule
