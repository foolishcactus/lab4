//`default_nettype none

module bricks (
    input logic [9:0] col, row,
    input logic update,
    input logic clear,
    input logic moveBall,
    input logic clock_40MHz,

    input logic [9:0] ballX, ballY,
    input logic ballVUp, ballVRight,

    output logic ballXFlip, ballYFlip,
    output logic yellowBrick, purpleBrick,
    output logic allBroken,
    output logic [13:0] broken
);

    logic [13:0] brickPixel;
    logic [13:0] brickXFlip, brickYFlip;

    // Top row
    brick #(70, 100, 100, 30) b0 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[0], brickYFlip[0], brickPixel[0], broken[0]
    );

    brick #(170, 100, 100, 30) b1 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[1], brickYFlip[1], brickPixel[1], broken[1]
    );

    brick #(270, 100, 100, 30) b2 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[2], brickYFlip[2], brickPixel[2], broken[2]
    );

    brick #(370, 100, 100, 30) b3 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[3], brickYFlip[3], brickPixel[3], broken[3]
    );

    brick #(470, 100, 100, 30) b4 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[4], brickYFlip[4], brickPixel[4], broken[4]
    );

    brick #(570, 100, 100, 30) b5 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[5], brickYFlip[5], brickPixel[5], broken[5]
    );

    brick #(670, 100, 50, 30) b6 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[6], brickYFlip[6], brickPixel[6], broken[6]
    );

    // Bottom row
    brick #(70, 150, 50, 30) b7 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[7], brickYFlip[7], brickPixel[7], broken[7]
    );

    brick #(120, 150, 100, 30) b8 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[8], brickYFlip[8], brickPixel[8], broken[8]
    );

    brick #(220, 150, 100, 30) b9 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[9], brickYFlip[9], brickPixel[9], broken[9]
    );

    brick #(320, 150, 100, 30) b10 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[10], brickYFlip[10], brickPixel[10], broken[10]
    );

    brick #(420, 150, 100, 30) b11 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[11], brickYFlip[11], brickPixel[11], broken[11]
    );

    brick #(520, 150, 100, 30) b12 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[12], brickYFlip[12], brickPixel[12], broken[12]
    );

    brick #(620, 150, 100, 30) b13 (
        col, row, update, clear, moveBall, clock_40MHz,
        ballX, ballY, ballVUp, ballVRight,
        brickXFlip[13], brickYFlip[13], brickPixel[13], broken[13]
    );

    // Combine all collision requests.
    assign ballXFlip = |brickXFlip;
    assign ballYFlip = |brickYFlip;

    // Assert when every brick is broken.
    assign allBroken = &broken;

    // Drawing signals for the Color module.
    assign yellowBrick =
        brickPixel[0] | brickPixel[2] | brickPixel[4] |
        brickPixel[6] | brickPixel[8] | brickPixel[10] |
        brickPixel[12];

    assign purpleBrick =
        brickPixel[1] | brickPixel[3] | brickPixel[5] |
        brickPixel[7] | brickPixel[9] | brickPixel[11] |
        brickPixel[13];

endmodule