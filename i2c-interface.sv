parameter SLAVE_SIZE=8;
parameter SLAVE_ADDR=7'b1001100;
module i2cinterface1(
                      memorysubsystem inst
                      
);

int count=0;
int i;
logic [SLAVE_SIZE-2:0] slave_addr;

//logic write;
// logic read;
// logic [inst.DATAWIDTH-1:0]data_out;
logic sdat;
logic sda_en=0;
logic sclclk=0;
logic sclt;
logic [7:0] sdaValues[$];
logic [7:0] data_output[$];

logic [inst.ADDRWIDTH-1:0]addrreg;
logic [inst.DATAWIDTH-1:0]data_out;

enum{idle_bit=0,
     start_bit=1,
     addr_bit=2,
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


assign slave_addr=SLAVE_ADDR;


always@(posedge inst.clk)
    begin
      if(count <= 9) 
        begin
           count <= count + 1;     
        end
      else
         begin
           count     <= 0; 
		   sclclk=~sclclk;
         end	      
    end

always_ff@(posedge sclclk or negedge inst.rst)
begin
 if(!inst.rst) 
 begin
      state<=idle_state;
	  sclt<=1;
      sdat<=1;
 end
 else begin 
 unique case(1'b1)
    state[idle_bit]:
	begin
	 sclt<=1;
     sdat<=1;
	 sda_en  <= 1'b1;
	 if(inst.enable) 
	        nextstate<=start_state;
	 else 
	        nextstate<=idle_state;
    end
	state[start_bit]:
	begin
	    sdat<=0;
        sclt<=1;
	    if(inst.enable)
	          nextstate<=addr_state;
		else
		      nextstate<=idle_state;
	end
	state[addr_bit]: 
	begin
	  sclt<=~sclt;
	  
	 if ((SLAVE_ADDR == slave_addr) && (count==0)) begin
	   nextstate <= rw_state;
	   inst.ack<='0;
	  end
	 else if((count!=0) && (SLAVE_ADDR ==slave_addr))begin
	   nextstate <=addr_state;
	   if(i<=7)begin
             sdat<=slave_addr[i];
             sdat<=inst.addr[i];
			 i<=i+1;
        end
	  end
	 else
	   nextstate<=idle_state;
	   
	end
	state[rw_bit]: begin
	nextstate<=ack1_state;
	sclt<=~sclt;
	if(slave_addr[SLAVE_SIZE]==0) 
            begin
              sdat<=slave_addr[SLAVE_SIZE];
              inst.write<=1;
              inst.read<=0;
            end
            else 
			begin
              sdat<=slave_addr[SLAVE_SIZE];
              inst.read<=1;
              inst.write<=0;
            end
	end
	state[ack1_bit]: begin
	nextstate<=data_state;
	inst.ack=1;
    sclt<=~sclt;
    sdat<=1;
	end
	state[data_bit]: 
	begin
	 sclt<=~sclt;
	 if(i<=0)
	   nextstate<=ack2_state;
	 else
	   nextstate<=data_state;
	   if(inst.write && (!inst.read))
            begin
               if(i<=7) begin
                sdat<=inst.data_in[i];
				data_out<=inst.data_in;
				i<=i+1;
			end
        end
	end
	state[ack2_bit]: begin
	nextstate<=stop_state;
	inst.ack<=1;
    sdat<=1;
    sclt<=~sclt;
	end
	state[stop_bit]: begin
	nextstate<=idle_state;
	sdat<=0;
    sclt<=1;
	end
// default: state<=nextstate;
 endcase
end
end

assign inst.mastersda=(sda_en==1'b0) ? sdat :1'bz;
assign inst.scl=((state==start_state)||(state==stop_state)) ? sclt : sclclk;

//Assertions of i2c-interface
//assertions to check for reset state
property p_resetstate;
  @(posedge inst.clk)
    (!inst.rst) |=> (state==idle_state);
endproperty
  a_check_reset_state: assert property (p_resetstate) else $error(" error at this assertion p_reset_state");
// assertion for checking idle state
property p_idle_state;
 @(posedge inst.clk)
   ((inst.enable) &&(state==idle_state)) |=> ((state==start_state) ||(state==idle_state));
endproperty
  a_check_idle_state: assert property (p_idle_state) else $error(" error at this assertion p_idle_state");
// assertion for checking start state
property p_start_state;
 @(posedge inst.clk)
   ((inst.enable) &&(state==start_state)) |=> ((state==addr_state) ||(state==idle_state));
endproperty
  a_check_start_state: assert property (p_start_state) else $error(" error at this assertion p_start_state");
 // assertion for checking addr_state
property p_addr_state;
 @(posedge inst.clk)
   (((SLAVE_ADDR == slave_addr) && (count==0)) &&(state==addr_state)) |=> (state==rw_state);
 endproperty
   a_check_addr_state: assert property (p_addr_state) else $error(" error at this assertion p_addr_state");
// assertion for checking addr_nextstate
property p_addr_nextstate;
  @(posedge inst.clk)
    (((SLAVE_ADDR == slave_addr) && (count!=0)) && (state==addr_state)) |=> ((state==addr_state) ||(state==idle_state));
endproperty
  a_check_addrnextstate: assert property (p_addr_nextstate) else $error ("error at this assertion p_addr_nextstate");
//assertion for checking read_write state
property p_read_write_state;
  @(posedge inst.clk)
   (state==rw_state) |=> (state==ack1_state);
endproperty
  a_check_rwstate: assert property (p_read_write_state) else $error(" error at this assertion p_read_write_state");
// assertion for checking ack1_state
property p_ack1_state;
 @(posedge inst.clk)
  (state==ack1_state) |=>(state==data_state);
endproperty
   a_check_ack1_state: assert property (p_ack1_state) else $error(" error at this assertion p_ack1_state");
// assertion for checking data state
property p_data_state;
 @(posedge inst.clk)
    ((count==0) && (state==data_state)) |=> ((state==data_state) ||(state==ack2_state));
endproperty
   a_check_data_state: assert property (p_data_state) else $error(" error at this assertion p_data_state");
// assertion for checking outputs in idle state
property p_idle_outputs;
  @(posedge inst.clk)
    (state==idle_state) |-> ((sdat==1) &&(sclt==1));
endproperty
  a_check_idle_outputs: assert property (p_idle_outputs) else $error(" error occured at this assertion p_idle_outputs");
// assertion for checking outputs in start state
property p_start_outputs;
  @(posedge inst.clk)
   (state==start_state) |-> ((inst.mastersda==0) &&(inst.scl==1));
endproperty
  a_check_start_outputs: assert property (p_start_outputs) else $error("error occured at this assertion p_start_outputs");


endmodule : i2cinterface1







	   
	 
	                 
	




