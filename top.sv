module topmodule;
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



enum{idle_bit=0,
     start_bit=1,
     addr_bit=2,
     rw_bit=3,
     ack1_bit=4,
     data_bit=5,
     ack2_bit=6,
     stop_bit=7}stAte_bit;

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
 bit [1:0] vals;
finalproject fp(.*);

always #10 clk = ~clk;

covergroup i2cinterface1 @(posedge clk);
option.at_least=1;
coverpoint state {
                   bins a1=(idle_state=> start_state);
				   bins a2=(idle_state=> idle_state);
				   bins a3=(start_state=>addr_state);
				   bins a4=(start_state=> idle_state);
				   bins a5=(addr_state=> rw_state);
				   bins a6=(addr_state=> idle_state);
				   bins a7=(rw_state=>ack1_state);
				   bins a8=(ack1_state=>data_state);
				   bins a9=(data_state=>ack2_state);
				   bins a10=(data_state=>data_state);
				   bins a11=(ack2_state=>stop_state);
				   bins a12=(stop_state=>idle_state);
				   }
endgroup

class randomization;
 rand bit [1:0] tr;
endclass
covergroup fsm @(posedge clk);
 coverpoint state;
 cross vals,state;
endgroup
initial begin
static i2cinterface1  coverfsm = new;
	static fsm fsmcover=new;
	static randomization random = new;
	// fsm fsmcover=new;
	static int coverage;
	do  begin 
	        assert (random.randomize());
			{MSBIn,LSBIn}<=random.tr;
			vals<=random.tr;
			coverage= coverfsm.get_coverage();
			$display("coverage=%d",coverage);
			@(negedge clk);
		end
	while(coverage<5);
	
end
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
