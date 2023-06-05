module I2CInterface_tb;
    // Inputs
    logic clk;
    logic rst;
    logic enable;
    logic scl;
    logic mastersda;
	
	
	logic [7:0]master_addr;
	logic [7:0]slave_addr;
    logic [7:0] data_in;
	logic [7:0] data_out;
    logic ack;

    // Instantiate the I2CInterface module
    memorysubsystem bus (clk,rst);
    i2cinterface1 i2c1(bus.i2c_master,master_addr,data_in,addr);
    memorycontroller mc1(bus.mc_slave);


// i2cinterface1 i2c1(.*);
    // Clock generation
    always #10 clk = ~clk;

    // Initialize signals
	
    

    // Assertions
    // always @(posedge clk) begin
        // assert_scl_high: assert (scl === 1) else $error("SCL is not high as expected.");

        // assert_sda_high: assert ((i2c_interface.state === IDLE || i2c_interface.state === STOP) && sda === 1)
            // else $error("SDA is not high as expected.");

        // assert_sda_low_start: assert (i2c_interface.state === START && sda === 0)
            // else $error("SDA is not low during START state.");

        // assert_data_transmission: assert (i2c_interface.state === DATA && received_bit === data_in[i2c_interface.count])
            // else $error("Data transmission error.");
    // end

    // Initialize inputs
    initial begin
        clk = 0;
        rst = 0;
        enable = 1;
		data_in=100;
		master_addr=50;
		slave_addr=50;
		$display("the outputs are %d %d %d %b %b",data_in,master_addr,slave_addr,i2c1.inst.mastersda,i2c1.inst.scl);
		@(negedge clk)
        rst = 1;
		@(negedge clk)
        enable = 1;
		data_in=120;
		master_addr=20;
		slave_addr=20;
		$display("the outputs are %d %b %d %d ",data_in,i2c1.inst.mastersda,master_addr,slave_addr);
		@(negedge clk)
		$display("the outputs are %d %b %d %d ",data_in,i2c1.inst.mastersda,master_addr,slave_addr);
		@(negedge clk)
		$display("the outputs are %d %b %d %d ",data_in,i2c1.inst.mastersda,master_addr,slave_addr);
		@(negedge clk)
		$display("the outputs are %d %b %d %d ",data_in,i2c1.inst.mastersda,master_addr,slave_addr);
		@(negedge clk)
		$display("the outputs are %d %b %d %d ",data_in,i2c1.inst.mastersda,master_addr,slave_addr);
		repeat (8)@(negedge clk)
		rst=1;
		enable = 0;
		data_in=200;
		master_addr=20;
		slave_addr=20;
		$display("the outputs are %d %d %d %d ",data_in,i2c1.inst.mastersda,master_addr,slave_addr);
        $finish;
    end
endmodule
