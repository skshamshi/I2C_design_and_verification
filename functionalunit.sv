parameter N = 8;
module functionalunit(
memorysubsystem instf, 
input logic [N-1:0]D, 
input logic [2:0]S, 
input logic MSBIn, 
input logic LSBIn,
input logic enable,
output logic [N-1:0]Q
);


logic [N-1:0] temp;
logic [7:0] M [N-1:0];	


genvar i;
generate
for (i = N-1; i >= 0; i--)
assign M[i] = { (i == 0) ? 1'b0 : Q[i-1],(i == N-1) ? Q[N-1] : Q[i+1],(i == 0) ? Q[N-1] : Q[i-1],(i == N-1) ? Q[0] : Q[i+1],(i == 0)? LSBIn : Q[i-1],(i == N-1) ? MSBIn  : Q[i+1],D[i],Q[i]};	
endgenerate

DFF shift[N-1:0] (bus.func, instf.rst, temp,enable,Q);	
Mux M1[N-1:0] (M, S,temp);			
endmodule

module DFF(
memorysubsystem instf, 
input logic D,
input logic enable,
output logic Q
);

always_ff@(posedge instf.clk, negedge instf.rst)
	begin
		if(~instf.rst)
			Q <= 1'b0;
		else if(enable)
		 	Q <= D;		
	end
endmodule 

module Mux(V, S,Y);
parameter N = 8;

input logic [N-1:0] V;
input logic [$clog2(N)-1 : 0] S;
output logic Y;

assign Y = V[S];

endmodule