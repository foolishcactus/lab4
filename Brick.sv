//`default_nettype none

module brick #(
    parameter LEFT_COL = 70,
    parameter TOP_ROW = 100,
    parameter WIDTH = 100,
    parameter HEIGHT = 30
) (
    input logic [9:0] col, row,
    input logic update,
    input logic clear,
    input logic moveBall,
    input logic clock_40MHz,

    input logic [9:0] ballX, ballY,
    input logic ballVUp, ballVRight,

    output logic ballXFlip, ballYFlip,
    output logic displayBrick,
    output logic broken
);

    logic [10:0] x, y;
    logic [10:0] nextBallX, nextBallY;
    logic [10:0] ballRight, ballBottom;

    logic overlapBrickX, overlapBrickY;
    logic nearLeft, nearRight, nearTop, nearBottom;
    logic collideLeft, collideRight, collideTop, collideBottom;

    logic brickXMatch, brickYMatch;
    logic collisionEnabled, loadBroken;

    assign x = ballX;
    assign y = ballY;

    assign ballRight = x + 11'd5;
    assign ballBottom = y + 11'd5;

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


    RangeCheck #(11) horizontalOverlap (
        .val(nextBallX),
        .low(LEFT_COL - 5),
        .high(LEFT_COL + WIDTH - 1),
        .is_between(overlapBrickX)
    );

    RangeCheck #(11) verticalOverlap (
        .val(nextBallY),
        .low(TOP_ROW - 5),
        .high(TOP_ROW + HEIGHT - 1),
        .is_between(overlapBrickY)
    );

    Comparator #(11) leftFace (
        .A(ballRight),
        .B(LEFT_COL - 1),
        .AeqB(nearLeft)
    );

    Comparator #(11) rightFace (
        .A(x),
        .B(LEFT_COL + WIDTH),
        .AeqB(nearRight)
    );

    RangeCheck #(11) topFace (
        .val(ballBottom),
        .low(TOP_ROW - 2),
        .high(TOP_ROW - 1),
        .is_between(nearTop)
    );

    RangeCheck #(11) bottomFace (
        .val(y),
        .low(TOP_ROW + HEIGHT),
        .high(TOP_ROW + HEIGHT + 1),
        .is_between(nearBottom)
    );

    assign collideLeft =
        ballVRight && nearLeft && overlapBrickY;

    assign collideRight =
        !ballVRight && nearRight && overlapBrickY;

    assign collideTop =
        !ballVUp && nearTop && overlapBrickX;

    assign collideBottom =
        ballVUp && nearBottom && overlapBrickX;

    // Broken bricks cannot request collisions.
    assign collisionEnabled = moveBall && !broken && !clear;

    assign ballXFlip =
        collisionEnabled && (collideLeft || collideRight);

    assign ballYFlip =
        collisionEnabled && (collideTop || collideBottom);

    assign loadBroken =
        update && !clear && (ballXFlip || ballYFlip);

    Register #(1) brokenRegister (
        .en(loadBroken),
        .clear(clear),
        .D(1'b1),
        .clock(clock_40MHz),
        .Q(broken)
    );

    OffsetCheck #(10) brickColumns (
        .val(col),
        .low(LEFT_COL),
        .delta(WIDTH - 1),
        .is_between(brickXMatch)
    );

    OffsetCheck #(10) brickRows (
        .val(row),
        .low(TOP_ROW),
        .delta(HEIGHT - 1),
        .is_between(brickYMatch)
    );

    assign displayBrick = !broken && brickXMatch && brickYMatch;

endmodule