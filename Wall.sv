`default_nettype none

/*
 note: ball coordinate (upper left pixel)
       so the actual range of ball will be (x, y) to (x + 6, y + 6)
*/
module Wall(
  input logic [9:0] col, row,
  input logic [9:0] ballX, ballY, // ball x, y coordinate input
  input logic ballVUp, ballVRight, // current moving direction of the ball
  output logic ballXFlip, ballYFlip, // 0 and 1, if collision with wall should be changing x or y direction of ball
  output logic wall // output to Color module, if the wall should be drawn
);

logic leftXMatch, rightXMatch, sideYMatch;
logic topXMatch, topYMatch;

// collision indicator
logic collideLeft, collideRight, collideTop;

// Display: 2 side walls
RangeCheck #(10) leftColWall(
    .val(col), .low(10'd20), .high(10'd49),
    .is_between(leftXMatch)
);

RangeCheck #(10) rightColWall(
    .val(col), .low(10'd750), .high(10'd779),
    .is_between(rightXMatch)
);

RangeCheck #(10) RowWall(
    .val(row), .low(10'd10), .high(10'd589),
    .is_between(sideYMatch)
);

// Display: Top wall
RangeCheck #(10) topColWall(
    .val(col), .low(10'd49), .high(10'd750),
    .is_between(topYMatch)
);

RangeCheck #(10) topRowWall(
    .val(row), .low(10'd10), .high(10'd39),
    .is_between(topXMatch)
);

// Output: wall high
assign wall = ((leftXMatch | rightXMatch) & sideYMatch)
              | (topXMatch & topYMatch);

// Collision: Wall & ball
RangeCheck #(10) leftCollide(
    .val(ballX), .low(10'd0), .high(10'd50),
    .is_between(collideLeft)
);

RangeCheck #(10) rightCollide(
    .val(ballX), .low(10'd749-10'd5), .high(10'd800),
    .is_between(collideRight)
);

RangeCheck #(10) topCollide(
    .val(ballY), .low(10'd0), .high(10'd40),
    .is_between(collideTop)
);

// output for flipping direction of ball if collide with wall
assign ballXFlip = collideRight | collideLeft;
assign ballYFlip = collideTop;


endmodule: Wall