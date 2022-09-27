module Pong (input i_Clk, input i_left_up, input i_left_down, input i_right_up, input i_right_down, input [9:0] i_col_num, input [9:0] i_row_num, output [2:0] o_reds, output [2:0] o_greens, output [2:0] o_blues);

parameter ACTIVE_COLS = 640;
parameter ACTIVE_ROWS = 480;

// use flip flops so that buttons can add or subtract to each side's paddle location
reg [8:0] r_left_mover = 240;
reg [8:0] r_right_mover = 240;

reg r_left_up = 0;
reg r_left_down = 0;
reg r_right_up = 0;
reg r_right_down = 0;

// gotta make left and right paddle locations with always blocks
always @ (posedge i_Clk)
	begin
	
	r_left_up <= i_left_up;
	r_left_down <= i_left_down;
	
	if ((r_left_up == 0) && (i_left_up == 1)) // aka left up button is pushed
		begin
		if (r_left_mover > 31)
			r_left_mover <= r_left_mover - 30;
		else
			r_left_mover <= 450;
		end
	else if ((r_left_down == 0) && (i_left_down == 1)) //aka left down button is pushed
		begin
		if (r_left_mover < 449)
			r_left_mover <= r_left_mover + 30;
		else
			r_left_mover <= 30;
		end
	
	else
		r_left_mover <= r_left_mover;
	end
	
always @ (posedge i_Clk)
	begin
	
	r_right_up <= i_right_up;
	r_right_down <= i_right_down;
	
	if ((r_right_down == 0) && (i_right_down == 1))	// aka right up button is pushed
		begin
		if (r_right_mover < 449)
			r_right_mover <= r_right_mover + 30;
		else
			r_right_mover <= 30;
		end
		
	else if ((r_right_up == 0) && (i_right_up == 1))
		begin
		if (r_right_mover > 31)
			r_right_mover <= r_right_mover - 30;
		else
			r_right_mover <= 450;
		end
	else
		r_right_mover <= r_right_mover;
	end

// We need to use registers for the color outputs
reg [2:0] r_rightPaddle_blues;
reg [2:0] r_rightPaddle_greens;
reg [2:0] r_rightPaddle_reds;

reg [2:0] r_leftPaddle_blues;
reg [2:0] r_leftPaddle_greens;
reg [2:0] r_leftPaddle_reds;

// now on every clock cycle use the row/col position to create the movable paddles
always @ (posedge i_Clk)
	begin
	// move the ball right and return it if it hits the paddle State Machine?
	
	//create left paddle in columns 5 - 10
	if (i_col_num > 5 && i_col_num < 10)
		begin
		if (i_row_num > (r_left_mover - 30) && i_row_num < (r_left_mover + 30))
			begin
			r_leftPaddle_blues <= 3'b111;
			r_leftPaddle_greens <= 3'b111;
			r_leftPaddle_reds <= 3'b111;
			end
		else
			begin
			r_leftPaddle_blues <= 3'b000;
			r_leftPaddle_greens <= 3'b000;
			r_leftPaddle_reds <= 3'b000;
			end
		end	

	//create right paddles in columns 630 - 635
	else if (i_col_num > (ACTIVE_COLS - 10) && i_col_num < (ACTIVE_COLS - 5))
		begin
		if (i_row_num > (r_right_mover - 30) && i_row_num < (r_right_mover + 30))
			begin
			r_rightPaddle_blues <= 3'b111;
			r_rightPaddle_greens <= 3'b111;
			r_rightPaddle_reds <= 3'b111;
			end
		else
			begin
			r_rightPaddle_blues <= 3'b000;
			r_rightPaddle_greens <= 3'b000;
			r_rightPaddle_reds <= 3'b000;
			end
		end
	
	// in any other columns these are zero
	else
		begin
		r_rightPaddle_blues <= 3'b000;
		r_rightPaddle_greens <= 3'b000;
		r_rightPaddle_reds <= 3'b000;
		r_leftPaddle_blues <= 3'b000;
		r_leftPaddle_greens <= 3'b000;
		r_leftPaddle_reds <= 3'b000;
		end
	end
	
// use these registers to represent the center of the ball	
reg [8:0] r_ball_row_center = 240;
reg [9:0] r_ball_col_center = 15;
// use this statemachine register and state parameters to go bw start, moving right, moving left, out of bounds
parameter START = 0;
parameter MOVERIGHT = 1;
parameter MOVELEFT = 2;
parameter OUT = 3;	
reg [2:0] BALLSTATE = OUT; // starting at out for the delay

//Another state machine register will keep track of the ball's vertical movement
parameter STRAIGHT = 0;
parameter UP = 1;
parameter DOWN = 2;
reg [2:0] VERTICALSTATE = STRAIGHT;
// also create a clock divider so that the ball doesn't fly at the speed of light
reg r_tenth = 0;
reg [14:0] r_clk_divider = 0;
parameter DIVIDER_MAX = 32750; // increase to make the ball move slower

always @ (posedge i_Clk)
	begin
	if (r_clk_divider < DIVIDER_MAX)
		r_clk_divider <= r_clk_divider + 1;
	else
		begin
		r_tenth <= ~r_tenth;
		r_clk_divider <= 0;
		end
	end

reg [9:0] r_delay = 0; // this delay register counts in the ball movement's OUT state before sending state back to start
	
// separate always block for ball movement at the posedge of the clock divider (currently around every millisecond, idk why i called it r_tenth)
always @ (posedge r_tenth)
	begin
	case(BALLSTATE)
		
		START:
			begin
			r_ball_row_center <= 240;
			r_ball_col_center <= 15;
			BALLSTATE <= MOVERIGHT;
			VERTICALSTATE <= STRAIGHT;
			end
		
		// increment the column center of the ball, then once it gets to the other side, is the paddle there? if yes go to moveleft, if no, out of bounds.
		MOVERIGHT:	
			begin
			if (r_ball_col_center < (ACTIVE_COLS - 15))
				begin
				r_ball_col_center <= r_ball_col_center + 1;
				case (VERTICALSTATE)
					STRAIGHT:
						r_ball_row_center <= r_ball_row_center;
					UP:
						begin
						if (r_ball_row_center > 5)
							r_ball_row_center <= r_ball_row_center - 1;
						else
							r_ball_row_center <= 474;
						end
					DOWN:
						begin
						if (r_ball_row_center < 474)
							r_ball_row_center <= r_ball_row_center + 1;
						else
							r_ball_row_center <= 5;
						end
				endcase
				end
			else
				begin
				if ((r_ball_row_center >= r_right_mover - 30) && (r_ball_row_center <= r_right_mover + 30))
					begin
					BALLSTATE <= MOVELEFT;
					if (r_ball_row_center == r_right_mover)
						VERTICALSTATE <= STRAIGHT;
					else if (r_ball_row_center > r_right_mover)
						VERTICALSTATE <= DOWN;
					else
						VERTICALSTATE <= UP;
					end
				else
					BALLSTATE <= OUT;
				end
			end
		
		// Same as moveright, but to the left now y'all
		MOVELEFT:
			begin
			if (r_ball_col_center > 15)
				begin
				r_ball_col_center <= r_ball_col_center - 1;
				case (VERTICALSTATE)
					STRAIGHT:
						r_ball_row_center <= r_ball_row_center;
					UP:
						begin
						if (r_ball_row_center > 5)
							r_ball_row_center <= r_ball_row_center - 1;
						else
							r_ball_row_center <= 474;
						end
					DOWN:
						begin
						if (r_ball_row_center < 474)
							r_ball_row_center <= r_ball_row_center + 1;
						else
							r_ball_row_center <= 5;
						end
				endcase
				end
			else
				begin
				if ((r_ball_row_center >= r_left_mover - 30) && (r_ball_row_center <= r_left_mover + 30))
					begin
					BALLSTATE <= MOVERIGHT;
					if (r_ball_row_center == r_left_mover)
						VERTICALSTATE <= STRAIGHT;
					else if (r_ball_row_center > r_left_mover)
						VERTICALSTATE <= DOWN;
					else
						VERTICALSTATE <= UP;
					end
				else
					BALLSTATE <= OUT;
				end
			end
		
		// if we're out of bounds, delay a moment then send to START, eventually add in scoring
		OUT:
			begin
			if (r_delay < 1000)
				r_delay <= r_delay + 1;
			else
				begin
				r_delay <= 0;
				BALLSTATE <= START;
				end
			end
		endcase
	end
	
// now that there is a register controlling the column center of the ball, let's actually create the ball
//again we need registers for the color outputs of the ball

reg [2:0] r_ball_reds;
reg [2:0] r_ball_blues;
reg [2:0] r_ball_greens;

always @ (posedge i_Clk)
	begin
	if ((i_col_num > r_ball_col_center - 5) && (i_col_num <= r_ball_col_center + 5))
		begin
		if ((i_row_num > r_ball_row_center - 5) && (i_row_num <= r_ball_row_center + 5))
			begin
			r_ball_blues <= 3'b111;
			r_ball_reds <= 3'b111;
			r_ball_greens <= 3'b111;
			end
		else
			begin
			r_ball_blues <= 3'b000;
			r_ball_reds <= 3'b000;
			r_ball_greens <= 3'b000;
			end
		end
	else
		begin
		r_ball_blues <= 3'b000;
		r_ball_reds <= 3'b000;
		r_ball_greens <= 3'b000;
		end
	end
	
assign o_reds = r_leftPaddle_reds | r_rightPaddle_reds | r_ball_reds;
assign o_blues = r_leftPaddle_blues | r_rightPaddle_blues | r_ball_blues;
assign o_greens = r_ball_greens | r_leftPaddle_greens | r_rightPaddle_greens;

endmodule
