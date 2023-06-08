module i2cinterface1(
  memorysubsystem inst, 
  input logic [7:0] master_addr, 
  input logic [7:0] data_in,
  input logic enable,
  output logic [7:0] masterdata
);

  int count;
  logic [7:0] slave_addr;
  logic ack;
  logic write;
  logic read;
  logic [7:0]sda_temp;
  logic [7:0]d_out;
 
assign slave_addr = master_addr;
  enum {
    idle_bit=0,
    start_bit=1,
    addr_bit=2,
    rw_bit=3,
    ack1_bit=4,
    data_bit=5,
    ack2_bit=6,
    stop_bit=7
  } state_bit;

  enum logic [7:0] {
    idle_state = 8'b00000001 << idle_bit,
    start_state = 8'b00000001 << start_bit,
    addr_state = 8'b00000001 << addr_bit,
    rw_state = 8'b00000001 << rw_bit,
    ack1_state = 8'b00000001 << ack1_bit,
    data_state = 8'b00000001 << data_bit,
    ack2_state = 8'b00000001 << ack2_bit,
    stop_state = 8'b00000001 << stop_bit
  } state, nextstate;

  // Queue to store data_in
  logic [7:0] data_in_queue[$];
  
  
  // Class to handle I2C operations
  class I2C;
    logic scl;
    logic sda;

    // Construct
    function new(logic scl, logic sda);
      this.scl = scl;
      this.sda = sda;
    endfunction

    // Start
    function void start();
      inst.mastersda = 0;
      inst.scl = 1;
    endfunction

    // Stop
    function void stop();
      inst.mastersda = 1;
      inst.scl = 1;
    endfunction

   // Write data 
    function logic [7:0] writeData(logic [7:0] data);
	logic [7:0] sdaValues[$];
	logic [7:0] outputData;
  
	foreach (data[i]) begin
    inst.mastersda = data[i];
    sdaValues.push_front(inst.mastersda); // Store the sda value in the array
    inst.scl = 0;
    inst.scl = 1;
	end
  
  // Concatenate the sda values 
  foreach (sdaValues[j]) begin
    outputData[j] = sdaValues[j];
  end
  
  return outputData;
  endfunction
  
    // Read data 
    function logic [7:0] readData();
      logic [7:0] data;
      sda = 1;
      foreach (data[i]) begin
        scl = 0;
        data[i] = sda;
        scl = 1;
      end
      return data;
    endfunction
  endclass

  // Create an instance of the I2C class
  I2C i2c = new(inst.scl, inst.mastersda);
  

  always_ff @(posedge inst.clk or negedge inst.rst) begin
    if (!inst.rst) begin
      state <= idle_state;
	  //masterdata <= data_in;
	  end
    else
      state <= nextstate;
  end

  always_comb begin
    nextstate = state;
    unique case (1'b1)
      state[idle_bit]:
        begin
          if (enable) begin 
            nextstate = start_state;
			//masterdata = data_in;
			end
          else begin
            nextstate = idle_state;
			//masterdata = data_in;
			end
        end
      state[start_bit]:
        nextstate = addr_state;
      state[addr_bit]: 
        begin
          if ((master_addr == slave_addr) && (count == 0))
            nextstate = rw_state;
          else if ((count != 0) && (master_addr == slave_addr))
            nextstate = addr_state;
          else
            nextstate = idle_state;
        end
      state[rw_bit]:
        nextstate = ack1_state;
      state[ack1_bit]:
        nextstate = data_state;
      state[data_bit]: 
        begin
          if (count == 0)
            nextstate = ack2_state;
          else
            nextstate = data_state;
        end
      state[ack2_bit]:
        nextstate = stop_state;
      state[stop_bit]:
        nextstate = idle_state;
    endcase
  end

  always_comb begin
    inst.mastersda = 1;
    //inst.scl = 1;
    unique case (1'b1)
      state[idle_bit]:
        begin
          //inst.scl = 1;
          inst.mastersda = 1;
          count = 8;
		  masterdata = data_in;
          data_in_queue.delete();
        end
      state[start_bit]: begin
        i2c.start();
		end
      state[addr_bit]:
        begin
          //inst.scl = ~inst.scl;
          if (count != 0) begin
            inst.mastersda = master_addr[count - 1];
            count = count - 1;
          end
          if (count == 0)
            ack = 1;
        end
      state[rw_bit]:
        begin
          //inst.scl = ~inst.scl;
          if (master_addr[7] == 0) begin
            inst.mastersda = 0;
            write = 1;
            read = 0;
          end
          else begin
            inst.mastersda = 1;
            read = 1;
            write = 0;
          end
        end
      state[ack1_bit]:
        begin
          ack = 1;
          inst.mastersda = 1;
        end
      state[data_bit]:
        begin
          inst.mastersda = 1;
          if (write) begin
		     masterdata = i2c.writeData(data_in);
            if (!data_in_queue.empty()) begin
              inst.mastersda = data_in_queue.pop_front();
              count = count - 1;
            end
          end
		end
      state[ack2_bit]:
        begin
          ack = 1;
          inst.mastersda = 1;
          //inst.scl = ~inst.scl;
        end
      state[stop_bit]:
        i2c.stop();
    endcase
  end
  
  always@(negedge inst.clk) begin
    if(inst.rst==1)  inst.scl<=1;
    else begin
             if((nextstate==idle_state)||(nextstate==start_state)||(nextstate==stop_state))  
                     inst.scl<=1;
            else    inst.scl<=~inst.scl;
         end 
end 

//assign d_out = data_in;

endmodule
