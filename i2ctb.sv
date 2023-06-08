module I2CInterface_tb;
    // Inputs
    logic clk;
    logic rst;
    logic enable;
    logic scl;
    logic mastersda;
	logic [7:0]masterdata;
	logic [7:0]master_addr;
	
	
	// logic [7:0]master_addr;
	logic [6:0]slave_addr;
    logic [7:0] data_in;
	logic [7:0] d_out;
    logic ack;
	logic [7:0]addr;

    // Instantiate the I2CInterface module
    memorysubsystem bus (clk,rst);
    i2cinterface1 i2c1(bus.i2c_master,master_addr,data_in,enable,masterdata);
    //memorycontroller mc1(bus.mc_slave);


    // Clock generation
    always #10 clk = ~clk;

    initial begin
    clk = 0;
    rst = 1;
    master_addr = 8'h00;
    data_in = 8'h00;
	enable = 1;

    @(negedge clk) rst = 0;
    @(negedge clk) master_addr = 8'h10;  // Set master address
    @(negedge clk) data_in = 8'b10101010;  // Set data input
      #10;
      $display("CLK: %0t, MASTER_ADDR: %h, DATA_IN: %h, MASTERDATA: %h", $time, master_addr, data_in, masterdata);


    $finish;
  end
endmodule
