//`default_nettype none

module Paddle (
    input  logic [9:0] col, row,
    input  logic update,
    input  logic clear,
    input  logic movePaddle,
    input  logic clock_40MHz,

    input  logic btn2_sync, btn3_sync,
    input  logic [9:0] ballX, ballY,
    input  logic ballVUp, ballVRight,

    output logic ballXFlip, ballYFlip,
    output logic paddle
);

    logic [9:0] paddleX;
    logic [9:0] nextPaddleX;
    logic [9:0] paddleXInput;

    logic paddleXMatch, paddleYMatch;

    logic [10:0] x, y;
    logic [10:0] nextBallX, nextBallY;
    logic [10:0] ballRight, ballBottom;
    // b/c paddle is moving, taking into account the exact position at the frame update timing 
    // (at update, position register changes at clock edge,
    // we need that new position to compare with our ball new position)
    logic [10:0] upToDatePaddleLeft;
    logic [10:0] upToDatePaddleRight;

    logic overlapPaddleX, overlapPaddleY;
    logic nearLeft, nearRight, nearTop;
    logic collideLeft, collideRight, collideTop;
    logic collisionEnabled;

    // Paddle movement: 8 pixels per update.
    // The 80-pixel paddle stays between columns 50 and 749.
    always_comb begin
        nextPaddleX = paddleX;

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

    assign paddleXInput = clear ? 10'd200 : nextPaddleX;

    Register #(10) xCoor (
        .en((update && movePaddle) || clear),
        .clear(1'b0),
        .D(paddleXInput),
        .clock(clock_40MHz),
        .Q(paddleX)
    );

    // Draw the current registered paddle position.
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

    assign paddle = paddleXMatch && paddleYMatch;

    // Predict the ball's next position before any bounce.
    assign x = {1'b0, ballX};
    assign y = {1'b0, ballY};

    assign ballRight  = x + 11'd5;
    assign ballBottom = y + 11'd5;

    always_comb begin
        if (ballVRight)
            nextBallX = x + 11'd1;
        else if (x > 11'd0)
            nextBallX = x - 11'd1;
        else
            nextBallX = 11'd0;

        if (ballVUp) begin
            if (y >= 11'd2)
                nextBallY = y - 11'd2;
            else
                nextBallY = 11'd0;
        end
        else begin
            nextBallY = y + 11'd2;
        end
    end

    // for the frame update cycle, 
    // should use the new paddle position for collision check
    assign upToDatePaddleLeft =
        (update && movePaddle)
        ? {1'b0, nextPaddleX}
        : {1'b0, paddleX};

    assign upToDatePaddleRight =
        upToDatePaddleLeft + 11'd79;

    // Overlap of the proposed ball position and paddle.
    // Proposed ball position overlaps the 80-pixel paddle.
    OffsetCheck #(11) paddleXOverlapCheck (
        .val(nextBallX),
        .low(upToDatePaddleLeft - 11'd5),
        .delta(11'd84),
        .is_between(overlapPaddleX)
    );

    RangeCheck #(11) paddleYOverlapCheck (
        .val(nextBallY),
        .low(11'd550),
        .high(11'd579),
        .is_between(overlapPaddleY)
    );

    // Horizontal speed is 1 pixel per update.
    Comparator #(11) paddleLeftTouchCheck (
        .A(ballRight + 11'd1),
        .B(upToDatePaddleLeft),
        .AeqB(nearLeft)
    );

    Comparator #(11) paddleRightTouchCheck (
        .A(x),
        .B(upToDatePaddleRight + 11'd1),
        .AeqB(nearRight)
    );

    // Vertical speed is 2 pixels per update.
    RangeCheck #(11) paddleTopTouchCheck (
        .val(ballBottom),
        .low(11'd553),
        .high(11'd554),
        .is_between(nearTop)
    );

    assign collideLeft =
        ballVRight && nearLeft && overlapPaddleY;

    assign collideRight =
        !ballVRight && nearRight && overlapPaddleY;

    assign collideTop =
        !ballVUp && nearTop && overlapPaddleX;

    assign collisionEnabled = movePaddle && !clear;

    assign ballXFlip =
        collisionEnabled && (collideLeft || collideRight);

    assign ballYFlip =
        collisionEnabled && collideTop;

endmodule : Paddle