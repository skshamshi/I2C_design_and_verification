module finalproject(input logic clk,rst);

memorysubsystem bus (clk,rst);
functionalunit funct1(bus.func, data_in, S, MSBIn, LSBIn,enable,Q);
i2cinterface1 i2c1(bus.i2c_master,master_addr,Q,enable,masterdata);
memorycontroller mc1(bus.mc_slave,masterdata,dataout,done); 
endmodule