module memorycontroller_tb;
  
  // Inputs
  reg clk;
  reg rst;
  reg scl;
  reg slavesda;
  reg [7:0]data;
  reg [7:0]dataout;
  
  // Outputs
  wire ack;
  
 // Instantiate the I2CInterface module
    memorysubsystem bus (clk,rst);
    //i2cinterface1 i2c1(bus.i2c_master);
    memorycontroller mc1(bus.mc_slave,data,dataout,ack);
  
  // Clock generation
  always begin
    #5 clk = ~clk; // Toggle the clock every 5 time units
  end
  
  // Reset initialization
  initial begin
    clk = 0;
    rst = 1;
    scl = 0;
    slavesda = 0;
    
   #10 rst = 0; // De-assert reset after 10 time units
  end
  
  // Test scenario
  initial begin
    data = 8'b11111111;
    // Perform memory write operation
    #10 scl = 1;
    #10 slavesda = 0;
    #10 scl = 0;
    
    // Write address (e.g., 0x05)
    #10 scl = 1;
    #10 slavesda = 1; // MSB
    #10 slavesda = 0;
    #10 slavesda = 1;
    #10 slavesda = 0;
    #10 slavesda = 1;
    #10 slavesda = 0;
    #10 slavesda = 1; // LSB
    #10 scl = 0;
    
    // Receive address acknowledgment
    #10 scl = 1;
    #10 slavesda = 1; // ACK
    #10 scl = 0;
    
    // Write data (e.g., 0xAB)
    #10 scl = 1;
    #10 slavesda = 1; // MSB
    #10 slavesda = 0;
    #10 slavesda = 1;
    #10 slavesda = 0;
    #10 slavesda = 1;
    #10 slavesda = 1;
    #10 slavesda = 0;
    #10 slavesda = 1; // LSB
    #10 scl = 0;
    
    // Receive data acknowledgment
    #10 scl = 1;
    #10 slavesda = 1; // ACK
    #10 scl = 0;
    
    // Stop condition
    #10 scl = 1;
    #10 slavesda = 0;
    #10 scl = 0;
    #10 slavesda = 1;
    
    // Wait for the acknowledgement
    #100;
    
    $display("ACK: %b OUT : %b", ack,dataout);
    
    $finish; // End the simulation
  end

endmodule
