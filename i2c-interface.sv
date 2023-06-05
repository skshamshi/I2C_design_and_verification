parameter DATAWIDTH=8;
parameter ADDRWIDTH=7;

module i2cinterface1(
memorysubsystem inst, 
input logic [6:0]master_addr, 
input logic [DATAWIDTH-1:0]data_in,
input logic [ADDRWIDTH-1:0]addr
);


int count=8;
logic [6:0] slave_addr;
// logic [7:0] data_out;
logic ack;
logic write;
logic read;


enum{idle_bit=0,
     start_bit=1,
     addr_bit=2
     rw_bit=3,
     ack1_bit=4,
     data_bit=5,
     ack2_bit=6,
     stop_bit=7}state_bit;

enum logic [7:0] {
                  idle_state=8'b00000001<<idle_bit,
                  start_state=8'b00000001<<start_bit,
                  addr_state=8'b00000001<<addr_bit,
                  rw_state=8'b00000001<<rw_bit,
                  ack1_state=8'b00000001<<ack1_bit,
                  data_state=8'b00000001<<data_bit,
                  ack2_state=8'b00000001<<ack2_bit,
                  stop_state=8'b00000001<<stop_bit
                  }state,nextstate;

always_ff@(posedge inst.clk or negedge inst.rst)
begin
 if(!inst.rst) state<=idle_state;
 else state<=nextstate;
end

always_comb
begin
 nextstate=state;
 unique case(1'b1)
    state[idle_bit]:
	begin
	 if(inst.enable) nextstate=start_state;
	 else nextstate=idle_state;
    end
	state[start_bit]:nextstate=addr_state;
	state[addr_bit]: 
	begin
	 if ((master_addr == slave_addr) && (count==0)) 
	   nextstate = rw_state;
	 else if((count!=0) && (master_addr ==slave_addr))
	   nextstate =addr_state;
	 else
	   nextstate=idle_state;
	end
	state[rw_bit]: nextstate=ack1_state;
	state[ack1_bit]: nextstate=data_state;
	state[data_bit]: 
	begin
	 if(count==0)
	   nextstate=ack2_state;
	 else
	   nextstate=data_state;
	end
	state[ack2_bit]: nextstate=stop_state;
	state[stop_bit]: nextstate=idle_state;
 endcase
end
always_comb
begin
// data_out='0;
inst.mastersda=1;
inst.scl=1;
unique case(1'b1)
state[idle_bit]:
begin
inst.scl=1;
inst.mastersda=1;
count=8;
end
state[start_bit]:
begin
inst.mastersda=0;
inst.scl=1;
end
state[addr_bit]:
begin
inst.scl=~inst.scl;
//inst.mastersda=1;
if(count!=0)begin
for(int i=0;i<count;i++)
  inst.mastersda=master_addr[count-1];
 // for(int i=0;i<count;i++)
 // slave_addr[i]=master_addr[count-i];
 count=count-1;
end
if(count==0)
ack=1;
end
state[rw_bit]:
begin
inst.scl=~inst.scl;
if(addr[7]==0) 
begin
inst.mastersda=0;
write=1;
read=0;
end
else begin
inst.mastersda=1;
read=1;
write=0;
end
end
state[ack1_bit]:
begin
ack=1;
inst.scl=~inst.scl;
inst.mastersda=1;
end
state[data_bit]:
begin
//inst.mastersda=1;
inst.scl=~inst.scl;
if(write && (!read))
begin
for(int j=8;j>count;j--)
inst.mastersda=data_in[j-1];
// for(int j=8;j>count;j--)
// data_out[j-count]=data_in[count];

end

end
state[ack2_bit]:
begin
ack=1;
inst.mastersda=1;
inst.scl=~inst.scl;
end
state[stop_bit]:
begin
inst.mastersda=0;
inst.scl=1;
end
endcase
end
endmodule : i2cinterface1







	   
	 
	                 
	




