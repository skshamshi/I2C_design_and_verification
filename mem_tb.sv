module memorycontroller_tb;
  
  // Inputs
  logic clk;
  logic rst;
  logic scl;
  logic slavesda;
  logic [7:0]data_in;
  logic [7:0]data_out;
  
  // Outputs
  wire ack;
  
 // Instantiate the I2CInterface module
    memorysubsystem bus (clk,rst);
    //i2cinterface1 i2c1(bus.i2c_master);
    memorycontroller mc1(bus.mc_slave,data_out);
  
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
    
	@(negedge clk)
    rst = 0; // De-assert reset after 10 time units
  end
  
  // Test scenario
  initial begin
    data_in = 8'b11111111;
    // Perform memory write operation
    @(negedge clk) scl = 1;
    @(negedge clk) slavesda = 0;
    @(negedge clk) scl = 0;
    
    // Write address (e.g., 0x05)
    @(negedge clk) scl = 1;
    @(negedge clk) slavesda = 1; // MSB
    @(negedge clk) slavesda = 0;
    @(negedge clk) slavesda = 1;
    @(negedge clk) slavesda = 0;
    @(negedge clk) slavesda = 1;
    @(negedge clk) slavesda = 0;
    @(negedge clk) slavesda = 1; // LSB
    @(negedge clk) scl = 0;
    
    // Receive address acknowledgment
    @(negedge clk) scl = 1;
    @(negedge clk) slavesda = 1; // ACK
    @(negedge clk) scl = 0;
    
    // Write data (e.g., 0xAB)
    @(negedge clk) scl = 1;
    @(negedge clk) slavesda = 1; // MSB
    @(negedge clk) slavesda = 0;
    @(negedge clk) slavesda = 1;
    @(negedge clk) slavesda = 0;
    @(negedge clk) slavesda = 1;
    @(negedge clk) slavesda = 1;
    @(negedge clk) slavesda = 0;
    @(negedge clk) slavesda = 1; // LSB
    @(negedge clk) scl = 0;
    
    // Receive data acknowledgment
    @(negedge clk) scl = 1;
    @(negedge clk) slavesda = 1; // ACK
    @(negedge clk) scl = 0;
    
    // Stop condition
    @(negedge clk) scl = 1;
    @(negedge clk) slavesda = 0;
    @(negedge clk) scl = 0;
    @(negedge clk) slavesda = 1;
    
    // Wait for the acknowledgement
    @(negedge clk);
    
    $display("ACK: %b OUT : %b", ack,data_out);
    
    $finish; // End the simulation
  end

endmodule