module I2CInterface_tb;
    // Inputs
    logic clk;
    logic rst;
    logic enable;
    logic scl;
    logic mastersda;
	logic sclclk=0;
	
	// logic [7:0]master_addr;
	logic [6:0]slave_addr;
    logic [7:0] data_in;
	logic [7:0] data_out;
    logic ack;
	logic [7:0]addr;
	logic write ,read;
	
int count=0;
int i;
logic sclt;
logic sdat;
logic sda_en;

    // Instantiate the I2CInterface module
    memorysubsystem bus (clk,rst);
    i2cinterface1 i2c1(bus.i2c_master);
    // memorycontroller mc1(bus.mc_slave);
	


    // Clock generation
    always #10 clk = ~clk;

    // Initialize inputs
    initial begin
	    
        clk = 0;
        rst = 0;
        enable = 1;
		data_in=100;   
	    addr=10;
		write=1;
		read=0;
		//$display("the outputs for the inputs are %b   %b  %b  %b ",data_in,i2c1.slave_addr,i2c1.inst.mastersda,i2c1.inst.scl);
		repeat(8)@(negedge clk)
        rst = 1;
		// $display("the outputs for the inputs are %b   %b %b  %b  ",data_in,i2c1.inst.mastersda,i2c1.slave_addr,i2c1.inst.scl);
		repeat(8)@(negedge clk)
		rst=0;
        enable=0;		
		//$display("the outputs for the inputs are  %b  %b %d  %b  ",data_in,i2c1.inst.mastersda,i2c1.slave_addr,i2c1.inst.scl); 
        $finish;
    end
endmodule
