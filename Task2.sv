// `default_nettype none

// brief: VGA protocol timiing interface
// output: row, col, HS, VS, blank

module VGA(
    input logic clock_40MHz,
    input logic reset,
    output logic HS, VS, blank,
    output logic [9:0] row, col
);
    // DATAPATH logics declaration
    // contorl points
    logic col_en, col_clr, row_clr, clk_en, clk_clr;
    logic display;
    // status points
    logic display_assert, BP_assert, pulse_assert;
    logic FP_assert, frame_finish; 
    logic [11:0] clk_cnt;
    // inner logic
    logic [9:0] col_Q, row_Q;
    logic one_row_finish;
    logic [9:0] row_raw;


    // FSM logics declaration
    enum logic [3:0] {INIT, VS_STATE, BP_V, ROW_DISPLAY,
                      HS_STATE, BP_H, PIXEL_DISPLAY, 
                      FP_H, FP_V
                     } next_state, state;

    // DATAPATH
    assign clk_en = 1;

    Counter #(10) ColCounter(
        .en(col_en),
        .clear(col_clr),
        .up(1'b1),
        .clock(clock_40MHz),
        .Q(col_Q)
    );

    Counter #(10) RowCounter(
        .en(one_row_finish),
        .clear(row_clr),
        .up(1'b1),
        .clock(clock_40MHz),
        .Q(row_Q)
    );

    Counter #(12) ClockCounter(
        .en(clk_en),
        .clear(clk_clr),
        .up(1'b1),
        .clock(clock_40MHz),
        .Q(clk_cnt)
    );

    Mux2to1 #(10) Mux1(
        .I0('x),
        .I1(col_Q),
        .S(display),
        .Y(col)
    );

    Comparator #(10) Comp1(
        .A(col_Q),
        .B(10'd799),
        .AeqB(one_row_finish)
    );

    RangeCheck #(10) RC1(
        .low(10'd27),
        .high(10'd626),
        .val(row_Q),
        .is_between(display_assert)
    );

    RangeCheck #(10) RC2(
        .low(10'd4),
        .high(10'd26),
        .val(row_Q),
        .is_between(BP_assert)
    );

    RangeCheck #(10) RC3(
        .low(10'd0),
        .high(10'd3),
        .val(row_Q),
        .is_between(pulse_assert)
    );

    Comparator #(10) Comp2(
        .A(row_Q),
        .B(10'd627),
        .AeqB(FP_assert)
    );

    Comparator #(10) Comp3(
        .A(row_Q),
        .B(10'd628),
        .AeqB(frame_finish)
    );

    Subtracter #(10) Sub1(
        .A(row_Q),
        .B(10'd27),
        .bin(1'b0),
        .diff(row_raw)
    );

    Mux2to1 #(10) Mux2(
        .I0('x),
        .I1(row_raw),
        .S(display),
        .Y(row)
    );

    // NEXT STATE LOGIC
    always_comb begin
        if (reset) next_state = INIT;
        else begin
            case (state)
                INIT: next_state = VS_STATE;
                VS_STATE: next_state = HS_STATE;
                BP_V: next_state = HS_STATE;
                ROW_DISPLAY: next_state = HS_STATE;
                HS_STATE: next_state = (clk_cnt == 126) ? BP_H: HS_STATE;
                BP_H: next_state = (clk_cnt == 214) ? PIXEL_DISPLAY:BP_H;
                PIXEL_DISPLAY: next_state = (clk_cnt == 1014) ? FP_H:PIXEL_DISPLAY;
                FP_H: begin
                    if (frame_finish) begin
                        if (clk_cnt == 12'd1053) next_state = FP_V;
                        else                     next_state = FP_H;
                    end
                    else if (clk_cnt == 1054) begin
                        if (pulse_assert) next_state = VS_STATE;
                        else if (BP_assert) next_state = BP_V;
                        else if (display_assert) next_state = ROW_DISPLAY;
                        else next_state = FP_V;
                    end
                    else next_state = FP_H;
                end
                FP_V: next_state = (frame_finish) ? VS_STATE : HS_STATE;
            endcase
        end
    end

    // FSM
    always_ff @(posedge clock_40MHz) begin
        state <= next_state;
    end
    
    // OUTPUT LOGIC
    assign VS = ~(pulse_assert || (state == FP_H && row_Q == 10'd4));

    always_comb begin
        // default case
        {HS, blank} = {1,1};
        {col_en, col_clr} = {0,0};
        row_clr = 0;
        clk_clr = 0;
        display = 0;
        // state dependent output
        case (state) 
            INIT: begin
                col_clr = 1;
                row_clr = 1;
                clk_clr = 1;
            end
            VS_STATE: begin
                HS = 0;
                col_clr = 1;
                clk_clr = 1;
            end
            BP_V: begin
                HS = 0;
                col_clr = 1;
                clk_clr = 1;
            end
            ROW_DISPLAY: begin
                HS = 0;
                col_clr = 1;
                clk_clr = 1;
            end
            HS_STATE: begin
                HS = 0;
            end
            PIXEL_DISPLAY: begin
                blank = ~display_assert;
                col_en = 1;
                display = display_assert;
            end
            FP_V: begin
                if (frame_finish) begin
                    row_clr = 1'b1;
                end
                else begin
                    HS = 1'b0;
                    col_clr = 1'b1;
                    clk_clr = 1'b1;
                end
            end
        endcase
    end
    

endmodule: VGA