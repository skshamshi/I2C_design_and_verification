module topmodule ;
logic clk;
logic rst;
logic [7:0] master_addr;
logic [7:0] data_in;
logic enable;
logic [7:0] dataout;
logic done;
logic [7:0]masterdata;
logic [7:0] Q;
reg Clock;
logic Clear;
logic [7:0] D;
logic [2:0] S;
logic MSBIn;
logic LSBIn;
logic [7:0] Y;

 
finalproject fp(.*);

always #10 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    master_addr = 8'h00;
    data_in = 8'b1000000;
	enable = 1;
	MSBIn = 1;
	LSBIn =1;
	S=3'b001;
    @(negedge clk);
	rst = 0;
    @(negedge clk);
	master_addr = 8'h10;  // Set master address
    @(negedge clk);
	rst = 1;
	@(negedge clk);
	  $display("DATAOUT: %b and DONE : %b",dataout,done);
      $finish;
end

endmodule