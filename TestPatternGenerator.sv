//`default_nettype none

module TestPatternGenerator (
    input  logic [9:0] row, col,
    output logic [7:0] red, green, blue
);

    logic red_range;
    logic green_range1, green_range2;
    logic blue_range1, blue_range2, blue_range3, blue_range4;
    logic bottom_half;

    // Red: columns 400-799
    RangeCheck #(10) r1 (
        .val(col),
        .low(10'd400),
        .high(10'd799),
        .is_between(red_range)
    );

    // Green: columns 200-399 and 600-799
    RangeCheck #(10) g1 (
        .val(col),
        .low(10'd200),
        .high(10'd399),
        .is_between(green_range1)
    );

    RangeCheck #(10) g2 (
        .val(col),
        .low(10'd600),
        .high(10'd799),
        .is_between(green_range2)
    );

    // Blue: columns 100-199, 300-399, 500-599, 700-799
    RangeCheck #(10) b1 (
        .val(col),
        .low(10'd100),
        .high(10'd199),
        .is_between(blue_range1)
    );

    RangeCheck #(10) b2 (
        .val(col),
        .low(10'd300),
        .high(10'd399),
        .is_between(blue_range2)
    );

    RangeCheck #(10) b3 (
        .val(col),
        .low(10'd500),
        .high(10'd599),
        .is_between(blue_range3)
    );

    RangeCheck #(10) b4 (
        .val(col),
        .low(10'd700),
        .high(10'd799),
        .is_between(blue_range4)
    );

    // Bottom half: rows 300-599
    RangeCheck #(10) bottom (
        .val(row),
        .low(10'd300),
        .high(10'd599),
        .is_between(bottom_half)
    );

    // Generate RGB outputs
    assign red = (red_range && !bottom_half)
                 ? 8'hFF : 8'h00;

    assign green = ((green_range1 || green_range2) && !bottom_half)
                   ? 8'hFF : 8'h00;

    assign blue = ((blue_range1 || blue_range2 ||
                    blue_range3 || blue_range4) && !bottom_half)
                  ? 8'hFF : 8'h00;
endmodule