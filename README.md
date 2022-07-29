# Pong-Game-on-FPGA-Verilog-
All Verilog modules for Pong video game created on Lattice FPGA (FPGA dev board provided by Nandland). 

Modules include 
Pong_Top - Call other modules and send final signals to FPGA
Debounce - Debounce the push buttons to avoid one button presses registering multiple button presses
sync_generator - create vertical and horizontal sync signals for VGA protocol. These tell the monitor when to read color signals
Pong - Create the game. Develop movable paddles and a moving ball that responds to the location of paddles
PorchShit - VGA has this weird thing called porches that help center the display
