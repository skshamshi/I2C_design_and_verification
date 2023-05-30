module FunctionalUnit(Q, Clock, Clear, D, S, MSBIn, LSBIn);
parameter N = 8;
output logic[N-1:0] Q;
input logic Clock;
input logic Clear;
input logic [N-1:0] D;
input logic [$clog2(N)-1:0] S;
input logic MSBIn;
input logic LSBIn;

logic [N-1:0]Y;
logic [7:0] Temp [N-1:0];

assign Temp[0] = {1'b0, Q[1], Q[N-1], Q[1], LSBIn, Q[1], D[0], Q[0]};
assign Temp[N-1] = {Q[N-2], Q[N-1], Q[N-2], Q[0], Q[N-2], MSBIn, D[N-1], Q[N-1]};

genvar i;
generate
	for(i = 1; i < N-1; i++)
	begin
		assign Temp[i] = {Q[i-1],Q[i+1],Q[i-1],Q[i+1],Q[i-1],Q[i+1],D[i],Q[i]};
	end
endgenerate
	
Mux DUT1 [N-1:0](Y, Temp, S);
DFF DUT2 [N-1:0] (Q, Clock, Clear, Y);

endmodule

module DFF(Q, Clock, Clear, D);
output logic Q;
input logic Clock,Clear, D;

always_ff@(posedge Clock, negedge Clear)
	begin
		if(~Clear)
			Q <= 1'b0;
		else
		 	Q <= D;		
	end
endmodule 

module Mux(Y, V, S);
parameter N = 8;
output logic Y;
input logic [N-1:0] V;
input logic [$clog2(N)-1 : 0] S;

assign Y = V[S];

endmodule