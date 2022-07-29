module sync_generator(input i_Clk, output reg [9:0] o_col_num = 0, output reg[9:0] o_row_num = 0, output o_h_sync, output o_v_sync);

parameter TOTAL_COLS = 800;
parameter TOTAL_ROWS = 525;
parameter ACTIVE_COLS = 640;
parameter ACTIVE_ROWS = 480;

always @ (posedge i_Clk)
	begin
	
	if (o_col_num < TOTAL_COLS)
		begin
		o_col_num <= o_col_num + 1;
		end
	
	else
		begin
		o_col_num <= 0;
		if (o_row_num < TOTAL_ROWS)
			begin
			o_row_num <= o_row_num + 1;
			end
		else
			begin
			o_row_num <= 0;
			end
		end
	
	end
	
assign o_h_sync = o_col_num < (ACTIVE_COLS) ? 1'b1 : 1'b0;
assign o_v_sync = o_row_num < (ACTIVE_ROWS) ? 1'b1 : 1'b0;

endmodule