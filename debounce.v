module debounce (input i_clk, input i_switch, output o_LED);

parameter MAX = 250000;
reg [17:0] r_counter = 0;
reg r_switch = 1'b0;

always @ (posedge i_clk)
	begin
	
	if (i_switch != r_switch && r_counter < MAX)
		begin
		r_counter <= r_counter + 1;
		end
	
	else if (r_counter == MAX)
		begin
		r_switch <= i_switch;
		r_counter <= 0;
		end
	
	else
		begin
		r_counter <= 0;
		end
	end
	
	assign o_LED = r_switch;
	
endmodule