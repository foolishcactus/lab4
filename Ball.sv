module Ball (
  input logic [9:0] row, col,
  input logic updateDisplay,
  input logic [1:0] changeXVeloc, changeYVeloc,
  output logic displayBall
);

//repeat for block, wall, paddle
//X pos/ypos registers

Register xCoord()
Register yCoord()
Register xVeloc()
Register yVeloc()

//combinational logic for checking if ball should be high based on col and row (use offsetcheck)

//combination logic for changing register velocities, and updating the coordinate registers
