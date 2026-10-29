module VelocityUpdate
(
  input logic [1:0] brickXVeloc, brickYVeloc, 
  input logic [1:0] paddleXVeloc, paddleYVeloc, 
  input logic [1:0] wallXVeloc, wallYVeloc,

  output logic [1:0] changeXVeloc, changeYVeloc
)