module memorycontroller(
  memorysubsystem instm, 
  input logic [7:0] data, 
  output logic [7:0] dataout,
  output logic ack
);
//Memory
reg [7:0] mem[128];

int i;
int count = 0;
logic [7:0] address;
logic [7:0] datain;
logic [7:0] read;
logic scl = 1;
logic slavesda = 0;
//logic enable = 0;
logic sda_final;
  
always@(posedge instm.clk) begin
      if(count <= 9) 
        count <= count + 1;     
      else
        count <= 0;        
end
    
enum {
    start_bit=0,
    store_bit=1,
    data_bit=2,
    ack_bit=3,
    stop_bit=4
  } state_bit;

  enum logic [4:0] {
    start_state = 5'b00001 << start_bit,
    store_state = 5'b00001 << store_bit,
	data_state = 5'b00001 << data_bit,
	ack_state = 5'b00001 << ack_bit,
    stop_state = 5'b00001 << stop_bit
  } state, nextstate;    
 
 
always@(posedge instm.clk or posedge instm.rst) begin 
      if(instm.rst == 1'b1) begin
	    state <=start_state;
        end
	 else begin
	    state<=nextstate;
      end
end	


always_comb begin
    nextstate = state;
    unique case (1'b1)
      state[start_bit]: begin
        //enable <= 1'b1;  
        if ((scl == 1'b1) && (slavesda == 1'b0)) begin
            nextstate <= store_state;
			end
        else begin
              nextstate <= start_state;   
			  end
          			  
    end
         
	  state[store_bit]: begin
        //enable <= 1'b1; ///read data
        if(i <= 7) begin
            i<= i + 1;
            address[i] <= instm.slavesda;
            read <= mem[address[7:1]]; 
            ack <= 1'b1; 
			dataout<=data;
			nextstate <= data_state;
        end
	    else begin
             i <= 0;
             //enable <= 1'b1; //store data
             nextstate <= stop_state; 
        end 
    end
 
         state [data_bit]: begin
            //enable <= 1'b0; //to send data
            if(i <= 7) begin
            i <= i + 1;
            sda_final <= read[i];
			nextstate <= ack_state;
            end
          else begin
             i <= 0;
             //enable <= 1'b1;
             nextstate <= stop_state; 
            end 
    end 
         
        state[ack_bit]: begin
           ack <= 1'b1;
           mem[address[7:1]] <= datain;
           nextstate <= stop_state;  	   
    end
		state[stop_bit]: begin
            //enable <= 1'b1;
            if( (instm.scl == 1'b1)&&(instm.slavesda == 1'b1) )
                nextstate <= start_state;
           else
                nextstate <= stop_state; 
    end
	
       endcase
end
        
assign instm.slavesda = sda_final;

 
endmodule