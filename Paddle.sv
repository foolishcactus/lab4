//`default_nettype none
//new
/* note: paddle coordinate range:
   80 pixels wide, 25 pixels high
   row, x: [555, 579]
   column, y: [50, 750 - 80] // in between walls
*/
// Coordinate naming in the code: X is column and Y is row.
module Paddle (
    input logic [9:0] col, row, // vga display coordinate
    input logic update, // whether to update the position of paddle
    input logic clear, // control point from FSM
    input logic movePaddle, // control point from FSM (high when in PLAY state)
    input logic clock_40MHz,
    input logic btn2_sync, btn3_sync,
    input logic [9:0] ballX, ballY, // ball x, y coordinate input
    input logic ballVUp, ballVRight, // current moving direction of the ball
    output logic ballXFlip, ballYFlip, // 0 and 1, if collision with wall should be changing x or y direction of ball
    output logic paddle // output to Color module, if the wall should be drawn
);

    logic [9:0] paddleX, nextPaddleX, paddleXInput;
    logic paddleXMatch, paddleYMatch;

    logic [10:0] x, y;
    logic [10:0] nextBallX, nextBallY;
    logic [10:0] ballRight, ballBottom;
    logic [10:0] paddleLeft, paddleRight;

    logic overlapPaddleX, overlapPaddleY;
    logic nearLeft, nearRight, nearTop;
    logic collideLeft, collideRight, collideTop;
    logic collisionEnabled;

    Mux2to1 #(10) nextPosition ( // next x coordinte, taking into account the default starting position
        .I0(nextPaddleX),
        .I1(10'd200), // custom start position
        .S(clear),
        .Y(paddleXInput)
    );

    // paddle x coordinate register
    Register #(10) xCoor (
        .en((update & movePaddle) | clear),
        .clear(1'b0), // never clearing because clear will set out x-coor to 0
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
    assign x = ballX;
    assign y = ballY;

    assign paddleLeft = paddleX;
    assign paddleRight = paddleLeft + 11'd79;

    assign ballRight = x + 11'd5;
    assign ballBottom = y + 11'd5;

    // Calculate the proposed position before bouncing.
    always_comb begin
        if (ballVRight)
            nextBallX = x + 11'd1;
        else if (x > 0)
            nextBallX = x - 11'd1;
        else
            nextBallX = 11'd0;

        if (ballVUp) begin
            if (y >= 2)
                nextBallY = y - 11'd2;
            else
                nextBallY = 11'd0;
        end
        else
            nextBallY = y + 11'd2;
    end

    // Horizontal overlap with the paddle.
    RangeCheck #(11) horizontalOverlap (
        .val(nextBallX),
        .low(paddleLeft - 11'd5),
        .high(paddleRight),
        .is_between(overlapPaddleX)
    );

    // Vertical overlap with paddle rows 555 through 579.
    RangeCheck #(11) verticalOverlap (
        .val(nextBallY),
        .low(11'd550),
        .high(11'd579),
        .is_between(overlapPaddleY)
    );

    // ball collides with left or right with paddle
    Comparator #(11) leftFace (
        .A(ballRight),
        .B(paddleLeft - 11'd1),
        .AeqB(nearLeft)
    );

    Comparator #(11) rightFace (
        .A(x),
        .B(paddleRight + 11'd1),
        .AeqB(nearRight)
    );

    // ball collides with paddle's top from above
    RangeCheck #(11) topFace (
        .val(ballBottom),
        .low(11'd553),
        .high(11'd554),
        .is_between(nearTop)
    );

    // Side hits require vertical overlap.
    assign collideLeft =
        ballVRight && nearLeft && overlapPaddleY;

    assign collideRight =
        !ballVRight && nearRight && overlapPaddleY;

    // Top hits require horizontal overlap.
    assign collideTop =
        !ballVUp && nearTop && overlapPaddleX;

    assign collisionEnabled = movePaddle && !clear;

    assign ballXFlip =
        collisionEnabled && (collideLeft || collideRight);

    assign ballYFlip =
        collisionEnabled && collideTop;

endmodule : Paddle