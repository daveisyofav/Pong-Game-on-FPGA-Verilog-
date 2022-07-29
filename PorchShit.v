module PorchShit(input i_Clk, input i_Vsync, input i_Hsync, input [9:0] i_col_num, input [9:0] i_row_num, output o_Vsync, output o_Hsync);

parameter TOTAL_COLS = 800;
parameter TOTAL_ROWS = 525;
parameter ACTIVE_COLS = 640;
parameter ACTIVE_ROWS = 480;

parameter H_FrontPorch = 18;
parameter H_BackPorch = 50;
parameter V_FrontPorch = 10;
parameter V_BackPorch = 33;

reg r_Hporch = 0;
reg r_Vporch = 0;

always @ (posedge i_Clk) 
	begin
	if ((i_col_num < (ACTIVE_COLS + H_FrontPorch)) | (i_col_num > (TOTAL_COLS - H_BackPorch - 2)))
		r_Hporch <= 1'b1;
	else 
		r_Hporch <= 1'b0;
	end

always @ (posedge i_Clk)
	begin
	if ((i_row_num < (ACTIVE_ROWS + V_FrontPorch)) | (i_row_num > (TOTAL_ROWS - V_BackPorch)))
		r_Vporch <= 1'b1;
	else
		r_Vporch <= 1'b0;
	end
	
assign o_Hsync = i_Hsync | r_Hporch;
assign o_Vsync = i_Vsync | r_Vporch;

endmodule