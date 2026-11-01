//`default_nettype none

module Score (
    input logic clock_40MHz,
    input logic clear,       
    input logic update,     
    input logic moveBall,    
    input logic ballMiss,

    output logic [3:0] score,
    output logic lifeLost,
    output logic noLives
);

    // Detect when all lives have been used
    Comparator #(4) zeroCheck (
        .A(score),
        .B(4'd0),
        .AeqB(noLives)
    );
    
    assign lifeLost = update && moveBall && ballMiss
                   && !noLives && !clear;

    // clear loads the starting count of 3
    // Each accepted miss subtracts one
    Counter #(4) livesCounter (
        .en(lifeLost),
        .clear(1'b0),
        .load(clear),
        .up(1'b0),
        .D(4'd3),
        .clock(clock_40MHz),
        .Q(score)
    );

endmodule