//`default_nettype none

module fsm (
    input logic CLOCK_40MHZ,
    input logic bricks_all_broken,
    input logic reset, // BTN0
    input logic start_game, // BTN1
    input logic update,
    input logic ball_miss, // connect to the ball_miss output of the ball module
    input logic [3:0] life_cnt, // from the life_cnt output of the score module
    // Connected to the existing Score module's score output.

    output logic score_deduct, // output to score module
    // paddle and ball control points: position should be freeze when not in PLAY state
    output logic moveBall, // to ball module, high when in PLAY state
    output logic movePaddle, // to paddle module, high when in PLAY state
    output logic clear, // to paddle and ball module, high when in INIT state
    output logic new_game,
    output logic won,
    output logic lost
);

    enum logic [1:0] {INIT, PLAY, WIN, LOSE} curState, nextState;
    logic previousStart, startPressed;

    // output logic
    // One request for each rising edge of the synchronized serve input.
    // Holding serve after restarting cannot immediately serve again.
    assign startPressed = start_game && !previousStart;

    assign moveBall = (curState == PLAY) && !reset;
    assign movePaddle = (curState == PLAY) && !reset;
    assign won = (curState == WIN);
    assign lost = (curState == LOSE);

    // Accept the miss on the same frame-update edge as Score.
    assign score_deduct = moveBall && update && ball_miss
                        && (life_cnt != 4'd0) && !bricks_all_broken;

    // Reset ball/paddle while waiting and on every accepted miss.
    // Including the miss resets the ball even when this is the last life.
    assign clear = reset || (curState == INIT) || score_deduct;

    // Only a whole-game restart restores bricks and all three lives.
    assign new_game = !reset && startPressed
                   && ((curState == WIN) || (curState == LOSE));

    // next state logic
    always_comb begin
        // default case
        nextState = curState; // stay in PLAY state if no event occurs during PLAY

        case (curState)
            INIT: begin
                if (startPressed)
                    nextState = PLAY;
            end

            PLAY: begin
                if (bricks_all_broken)
                    nextState = WIN;
                else if (life_cnt == 4'd0)
                    nextState = LOSE;
                else if (score_deduct) begin
                    // This is the count BEFORE the decrement on this edge.
                    if (life_cnt == 4'd1)
                        nextState = LOSE;
                    else
                        nextState = INIT;
                end
            end

            WIN: begin
                if (startPressed)
                    nextState = INIT;
            end

            LOSE: begin
                if (startPressed)
                    nextState = INIT;
            end

            default: nextState = INIT;
        endcase
    end

    // state transition logic
    always_ff @(posedge CLOCK_40MHZ) begin
        // default
        if (reset) begin
            curState <= INIT;
            previousStart <= 1'b0;
        end
        else begin
            curState <= nextState;
            previousStart <= start_game;
        end
    end

endmodule