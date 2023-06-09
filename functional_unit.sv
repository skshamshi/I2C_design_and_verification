parameter N = 8;
module FunctionalUnit(
	memorysubsystem instf,
	output logic[N-1:0] Q,
	input logic [N-1:0] D,
	input logic [$clog2(N)-1:0] S,
	input logic MSBIn,
	input logic LSBIn);

	logic [N-1:0]temp;
	logic [7:0] M [N-1:0];

genvar i;
generate
for (i = N-1; i >= 0; i--)
assign M[i] = { (i == 0) ? 1'b0 : Q[i-1],(i == N-1) ? Q[N-1] : Q[i+1],(i == 0) ? Q[N-1] : Q[i-1],(i == N-1) ? Q[0] : Q[i+1],(i == 0)? LSBIn : Q[i-1],(i == N-1) ? MSBIn  : Q[i+1],D[i],Q[i]};	
endgenerate
	
	Mux DUT1 [N-1:0](M, S, temp);
	DFF DUT2 [N-1:0] (bus.func, instf.rst, temp, enable,Q);

endmodule

module DFF(memorysubsystem instf, 
input logic D,
input logic enable,
output logic Q
);

	always_ff@(posedge instf.clk or negedge instf.rst )
	begin
		if(~instf.rst)
			Q <= 1'b0;
		else
		 	Q <= D;		
	end
endmodule 

module Mux(V, S, Y);
parameter N = 8;
output logic Y;
input logic [N-1:0] V;
input logic [$clog2(N)-1 : 0] S;

assign Y = V[S];

endmodule
