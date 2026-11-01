//`default_nettype none

module Ball (
  input logic [9:0] row, col,
  input logic updateDisplay,
  input logic clear, // control point from FSM
  input logic clock_40MHz,
  input  logic moveBall, // control point from FSM, if in PLAY state
  input logic paddleXFlip, bricksXFlip, wallXFlip,
  input logic paddleYFlip, bricksYFlip, wallYFlip,
  output logic [9:0] ballX, ballY,
  output logic ballVUp, ballVRight,
  output logic ballMiss, // exceed the lower bound, lose
  output logic displayBall
);

  logic xFlip, yFlip;
  logic nextBallVUp, nextBallVRight;
  logic [9:0] nextBallX, nextBallY; // raw next pos
  logic [9:0] next_x_pos, next_y_pos; // actual input to pos resgiter,
                                      // accounting default starting pos
  logic next_x_veloc, next_y_veloc;

  // display or no
  logic ballXMatch, ballYMatch;

  assign xFlip = paddleXFlip | bricksXFlip | wallXFlip;
  assign yFlip = paddleYFlip | bricksYFlip | wallYFlip;
  // only calculate nextBallVRight during update to avoid constantly flipping direction
  // that being said, the next position calculation for ball also needs to be based on next velocity
  assign nextBallVRight = updateDisplay ? (ballVRight ^ xFlip) : ballVRight;  
  assign nextBallVUp = updateDisplay ?  (ballVUp ^ yFlip) : ballVUp;
  assign nextBallX =  (nextBallVRight)? ballX + 10'd1: ballX - 10'd1;
  assign nextBallY = (nextBallVUp)? ballY - 10'd2: ballY + 10'd2;

  // update position register
  Register #(10) xCoord(
    .en((moveBall & updateDisplay) | clear), .clear(1'b0),
    .D(next_x_pos), .clock(clock_40MHz), .Q(ballX)
  );

  Register #(10) yCoord(
    .en((moveBall & updateDisplay) | clear), .clear(1'b0), 
    .D(next_y_pos), .clock(clock_40MHz), .Q(ballY)
  );

  // right is 1, left is 0
  // up is 1, down is 0
  DFlipFlop velocityRight(
    .D(next_x_veloc), .clock(clock_40MHz), 
    .preset_L(1'b1), .reset_L(1'b1), .Q(ballVRight)
  );

  DFlipFlop velocityUp(
    .D(next_y_veloc), .clock(clock_40MHz), 
    .preset_L(1'b1), .reset_L(1'b1), .Q(ballVUp)
  );

  // ball position and velocity update logic
  Mux2to1 #(10) nextXPos (
    .I0(nextBallX), .I1(10'd400),
    .S(clear), .Y(next_x_pos)
  );

  Mux2to1 #(10) nextYPos (
      .I0(nextBallY), .I1(10'd420),
      .S(clear), .Y(next_y_pos)
  );

  Mux2to1 #(1) NextXVelocity (
      .I0(nextBallVRight), .I1(1'b1),
      .S(clear), .Y(next_x_veloc)
  );

  Mux2to1 #(1) NextYVelocity (
      .I0(nextBallVUp), .I1(1'b1),
      .S(clear), .Y(next_y_veloc)
  );

  // Display 
  OffsetCheck #(10) ballColumns (
    .val(col), .low(ballX), .delta(10'd5),
    .is_between(ballXMatch)
  );

  OffsetCheck #(10) ballRows (
      .val(row), .low(ballY), .delta(10'd5),
      .is_between(ballYMatch)
  );

  assign displayBall = ballXMatch & ballYMatch;

  // if ball is out of lower bonud -> lose one life
  assign ballMiss = ~ballVUp & (ballY >= 10'd594);
endmodule : Ball