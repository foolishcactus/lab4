//`default_nettype none

module ChipInterface (
    input logic CLOCK_100,
    input logic [3:0] BTN,
    input logic [15:0] SW,

    output logic [3:0] D2_AN, D1_AN,
    output logic [7:0] D2_SEG, D1_SEG,

    output logic HDMI_CLOCK_N, HDMI_CLOCK_P,
    output logic [2:0] HDMI_TX_P, HDMI_TX_N
);

    logic clock_40MHz, clock_200MHz, locked;
    logic reset_button, reset;
    logic btn1_sync, btn2_sync, btn3_sync;

    logic [9:0] row, col;
    logic HS, VS, blank;
    logic game_update;
    logic [7:0] red, green, blue;

    logic [3:0] score;
    logic lifeLost, noLives, allBroken;

    clk_wiz_0 clk_wiz (
        .clk_out1(clock_40MHz),
        .clk_out2(clock_200MHz),
        .reset(1'b0),
        .locked(locked),
        .clk_in1(CLOCK_100)
    );

    Synchronizer reset_sync (
        .async(BTN[0]),
        .clock(clock_40MHz),
        .sync(reset_button)
    );

    Synchronizer serve_sync (
        .async(BTN[1]),
        .clock(clock_40MHz),
        .sync(btn1_sync)
    );

    Synchronizer left_sync (
        .async(BTN[2]),
        .clock(clock_40MHz),
        .sync(btn2_sync)
    );

    Synchronizer right_sync (
        .async(BTN[3]),
        .clock(clock_40MHz),
        .sync(btn3_sync)
    );

    assign reset = reset_button || !locked;

    VGA vga (
        .clock_40MHz(clock_40MHz),
        .HS(HS),
        .VS(VS),
        .blank(blank),
        .row(row),
        .col(col)
    );

    assign game_update =
        (row == 10'd600) && (col == 10'd800);

    Breakout game (
        .clock_40MHz(clock_40MHz),
        .reset(reset),
        .game_update(game_update),

        .row(row),
        .col(col),
        .btn1_sync(btn1_sync),
        .btn2_sync(btn2_sync),
        .btn3_sync(btn3_sync),

        .red(red),
        .green(green),
        .blue(blue),
        .score(score),
        .lifeLost(lifeLost),
        .noLives(noLives),
        .allBroken(allBroken)
    );

    assign D2_AN = 4'b1111;
    assign D1_AN = 4'b1111;
    assign D2_SEG = 8'hFF;
    assign D1_SEG = 8'hFF;

    hdmi_tx_0 vga_to_hdmi (
        .pix_clk(clock_40MHz),
        .pix_clkx5(clock_200MHz),
        .pix_clk_locked(locked),
        .rst(reset),

        .red(red),
        .green(green),
        .blue(blue),
        .hsync(HS),
        .vsync(VS),
        .vde(~blank),

        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),

        .TMDS_CLK_P(HDMI_CLOCK_P),
        .TMDS_CLK_N(HDMI_CLOCK_N),
        .TMDS_DATA_P(HDMI_TX_P),
        .TMDS_DATA_N(HDMI_TX_N)
    );

endmodule