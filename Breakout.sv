//`default_nettype none

module Breakout (
    input logic clock_40MHz,
    input logic reset,
    input logic game_update,

    input logic [9:0] row, col,
    input logic btn1_sync, btn2_sync, btn3_sync,

    output logic [7:0] red, green, blue,
    output logic [3:0] score,
    output logic lifeLost, noLives, allBroken
);

    logic clearGame, clearObjects, ballUpdate;
    logic new_game, moveBall, movePaddle, scoreDeduct;
    logic won, lost;
    logic [9:0] ballX, ballY;
    logic ballVUp, ballVRight, ballMiss;

    logic displayBall, displayPaddle, displayWall;
    logic yellowBrick, purpleBrick;

    logic paddleXFlip, paddleYFlip;
    logic bricksXFlip, bricksYFlip;
    logic wallXFlip, wallYFlip;
    logic [13:0] broken;

    assign clearGame = reset || new_game;

    assign ballUpdate = game_update && moveBall;

    fsm controller (
        .CLOCK_40MHZ(clock_40MHz),
        .bricks_all_broken(allBroken),
        .reset(reset),
        .start_game(btn1_sync),
        .update(game_update),
        .ball_miss(ballMiss),
        .life_cnt(score),
        .score_deduct(scoreDeduct),
        .moveBall(moveBall),
        .movePaddle(movePaddle),
        .clear(clearObjects),
        .new_game(new_game),
        .won(won),
        .lost(lost)
    );

    Ball ball_inst (
        .row(row),
        .col(col),
        .updateDisplay(ballUpdate),
        .clear(clearObjects),
        .clock_40MHz(clock_40MHz),
        .moveBall(moveBall),

        .paddleXFlip(paddleXFlip),
        .bricksXFlip(bricksXFlip),
        .wallXFlip(wallXFlip),
        .paddleYFlip(paddleYFlip),
        .bricksYFlip(bricksYFlip),
        .wallYFlip(wallYFlip),

        .ballX(ballX),
        .ballY(ballY),
        .ballVUp(ballVUp),
        .ballVRight(ballVRight),
        .ballMiss(ballMiss),
        .displayBall(displayBall)
    );

    Paddle paddle_inst (
        .col(col),
        .row(row),
        .update(game_update),
        .clear(clearObjects),
        .movePaddle(movePaddle),
        .clock_40MHz(clock_40MHz),

        .btn2_sync(btn2_sync),
        .btn3_sync(btn3_sync),
        .ballX(ballX),
        .ballY(ballY),
        .ballVUp(ballVUp),
        .ballVRight(ballVRight),

        .ballXFlip(paddleXFlip),
        .ballYFlip(paddleYFlip),
        .paddle(displayPaddle)
    );

    Wall wall_inst (
        .col(col),
        .row(row),
        .ballX(ballX),
        .ballY(ballY),
        .ballVUp(ballVUp),
        .ballVRight(ballVRight),

        .ballXFlip(wallXFlip),
        .ballYFlip(wallYFlip),
        .wall(displayWall)
    );

    bricks bricks_inst (
        .col(col),
        .row(row),
        .update(game_update),
        .clear(clearGame),
        .moveBall(moveBall),
        .clock_40MHz(clock_40MHz),

        .ballX(ballX),
        .ballY(ballY),
        .ballVUp(ballVUp),
        .ballVRight(ballVRight),

        .ballXFlip(bricksXFlip),
        .ballYFlip(bricksYFlip),
        .yellowBrick(yellowBrick),
        .purpleBrick(purpleBrick),
        .allBroken(allBroken),
        .broken(broken)
    );

    Score score_inst (
        .clock_40MHz(clock_40MHz),
        .clear(clearGame),
        .update(game_update),
        .moveBall(moveBall),
        .ballMiss(scoreDeduct),

        .score(score),
        .lifeLost(lifeLost),
        .noLives(noLives)
    );

    Color color_inst (
        .ball(displayBall),
        .wall(displayWall),
        .paddle(displayPaddle),
        .yellow_brick(yellowBrick),
        .purple_brick(purpleBrick),
        .won(won),
        .lost(lost),

        .red(red),
        .green(green),
        .blue(blue)
    );

endmodule