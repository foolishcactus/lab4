//`default_nettype none

/* note: paddle coordinate range:
   80 pixels wide, 25 pixels high
   row, x: [555, 579]
   column, y: [50, 750 - 80] // in between walls
*/
module Paddle(
  input logic [9:0] col, row, // vga display coordinate
  input update, // whether to update the position of paddle
  input clear, // control point from FSM
  input  logic movePaddle, // control point from FSM (high when in PLAY state)
  input clock_40MHz,
  input logic btn2_sync, btn3_sync,
  input logic [9:0] ballX, ballY, // ball x, y coordinate input
  input logic ballVUp, ballVRight, // current moving direction of the ball
  output logic ballXFlip, ballYFlip, // 0 and 1, if collision with wall should be changing x or y direction of ball
  output logic paddle // output to Color module, if the wall should be drawn
);
    logic [9:0] paddleX, nextPaddleX, paddleXInput;
    logic paddleColumns, paddleRows;
    logic paddleXMatch, paddleYMatch;

    Mux2to1 #(10) nextPosition ( // next x coordinte, taking into account the default starting position
        .I0(nextPaddleX),
        .I1(10'd200), // custom start position
        .S(clear),
        .Y(paddleXInput)
    );

    // paddle x coordinate register
    Register #(10) xCoor(
        .en((update & movePaddle) | clear), .clear(0), // never clearing because clear will set out x-coor to 0
        .D(paddleXInput),
        .clock(clock_40MHz),
        .Q(paddleX)
    );

    // determine paddle next position
    always_comb begin
        nextPaddleX = paddleX; // default case

        if (btn2_sync && !btn3_sync) begin
            if (paddleX <= 10'd50 + 10'd8)
                nextPaddleX = 10'd50;
            else
                nextPaddleX = paddleX - 10'd8;
        end
        else if (btn3_sync && !btn2_sync) begin
            if (paddleX >= 10'd670 - 10'd8)
                nextPaddleX = 10'd670;
            else
                nextPaddleX = paddleX + 10'd8;
        end
    end

    // Display paddle resolve
    OffsetCheck #(10) paddleColumnsCheck (
        .val(col),
        .low(paddleX),
        .delta(10'd79),
        .is_between(paddleXMatch)
    );

    RangeCheck #(10) paddleRowsCheck (
        .val(row),
        .low(10'd555),
        .high(10'd579),
        .is_between(paddleYMatch)
    );

    assign paddle = paddleXMatch & paddleYMatch;


    // colision with ball detection

    // the next possition of ball
    logic [9:0] paddleRight;
    logic [9:0] leftTouchX;
    logic collideLeft, collideRight, collideTop;
    logic overlapPaddleX, overlapPaddleY, ballAbovePaddle;

    assign paddleRight = paddleX + 10'd79;

    // ball collides with left or right with paddle
    RangeCheck #(10) leftCollide (
        .val(ballX + 10'd5),
        .low(paddleX - 10'd1),
        .high(paddleX + 10'd40), // plus half of the width of paddle
        .is_between(collideLeft)
    );

    RangeCheck #(10) rightCollide (
        .val(ballX),
        .low(paddleRight - 10'd40),
        .high(paddleRight + 10'd1),
        .is_between(collideRight)
    );

    // ball collides with paddle's top from above
    RangeCheck #(10) topCollide (
        .val(ballY+10'd5),
        .low(10'd554),
        .high(10'd579),
        .is_between(collideTop)
    );

    assign ballXFlip = (ballVRight  & collideLeft & collideTop) |
                       (~ballVRight & collideRight & collideTop);

    assign ballYFlip = ~ballVUp & (collideTop & (collideLeft | collideRight));


endmodule: Paddle