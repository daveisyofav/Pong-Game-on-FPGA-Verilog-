module Pong_Top (input i_Clk, input i_Switch_2, input i_Switch_1, input i_Switch_3, input i_Switch_4,
   output o_VGA_HSync,
   output o_VGA_VSync,
   output o_VGA_Red_0,
   output o_VGA_Red_1,
   output o_VGA_Red_2,
   output o_VGA_Grn_0,
   output o_VGA_Grn_1,
   output o_VGA_Grn_2,
   output o_VGA_Blu_0,
   output o_VGA_Blu_1,
   output o_VGA_Blu_2);
   
wire w_switch_1;
wire w_switch_2;
wire w_switch_3;
wire w_switch_4;

// debounce switches
debounce debounceinit(.i_clk(i_Clk), .i_switch(i_Switch_1), .o_LED(w_switch_1));
debounce debounceinit2(.i_clk(i_Clk), .i_switch(i_Switch_2), .o_LED(w_switch_2));
debounce debounceinit3(.i_clk(i_Clk), .i_switch(i_Switch_3), .o_LED(w_switch_3));
debounce debounceinit4(.i_clk(i_Clk), .i_switch(i_Switch_4), .o_LED(w_switch_4));

wire [9:0] w_col_num;
wire [9:0] w_row_num;
wire w_firstHsync;
wire w_firstVsync;

sync_generator sync_generatorinit(.i_Clk(i_Clk), .o_col_num(w_col_num), .o_row_num(w_row_num), .o_h_sync(w_firstHsync), .o_v_sync(w_firstVsync));

wire [2:0] w_reds;
wire [2:0] w_blues;
wire [2:0] w_greens;

Pong Ponginit(.i_Clk(i_Clk), .i_left_up(w_switch_1), .i_left_down(w_switch_2), .i_right_up(w_switch_3), .i_right_down(w_switch_4), .i_col_num(w_col_num), .i_row_num(w_row_num), .o_reds(w_reds), .o_greens(w_greens), .o_blues(w_blues));

wire w_FinalVsync;
wire w_FinalHsync;
   
PorchShit PorchShitinit(.i_Clk(i_Clk), .i_Vsync(w_firstVsync), .i_Hsync(w_firstHsync), .i_col_num(w_col_num), .i_row_num(w_row_num), .o_Vsync(w_FinalVsync), .o_Hsync(w_FinalHsync));

//make final assignments to outputs
assign o_VGA_HSync = w_FinalHsync;
assign o_VGA_VSync = w_FinalVsync;
assign o_VGA_Red_0 = w_reds[0];
assign o_VGA_Red_1 = w_reds[1];
assign o_VGA_Red_2 = w_reds[2];
assign o_VGA_Grn_0 = w_greens[0];
assign o_VGA_Grn_1 = w_greens[1];
assign o_VGA_Grn_2 = w_greens[2];
assign o_VGA_Blu_0 = w_blues[0];
assign o_VGA_Blu_1 = w_blues[1];
assign o_VGA_Blu_2 = w_blues[2];
	
endmodule	
   
