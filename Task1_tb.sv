//`default_nettype none

module range_offset_test ();

    logic [2:0] val, low, high, delta;
    logic range_result, offset_result;
    logic expected_range, expected_offset;

    logic [3:0] test_num;
    logic [15:0] errors;

    RangeCheck #(.WIDTH(3)) range_dut (
        .val(val),
        .low(low),
        .high(high),
        .is_between(range_result)
    );

    OffsetCheck #(.WIDTH(3)) offset_dut (
        .val(val),
        .low(low),
        .delta(delta),
        .is_between(offset_result)
    );

    initial begin
        val = 3'd0;
        low = 3'd0;
        high = 3'd0;
        delta = 3'd0;
        errors = 16'd0;

        for (test_num = 4'd0;
             test_num < 4'd9;
             test_num = test_num + 4'd1) begin

            // Default: [2, 5] for both modules
            low = 3'd2;
            high = 3'd5;
            delta = 3'd3;
            val = 3'd0;
            expected_range = 1'b0;
            expected_offset = 1'b0;

            case (test_num)
                // Below the range
                4'd0: val = 3'd1;

                // At the lower boundary
                4'd1: begin
                    val = 3'd2;
                    expected_range = 1'b1;
                    expected_offset = 1'b1;
                end

                // Inside the range
                4'd2: begin
                    val = 3'd3;
                    expected_range = 1'b1;
                    expected_offset = 1'b1;
                end

                // At the upper boundary
                4'd3: begin
                    val = 3'd5;
                    expected_range = 1'b1;
                    expected_offset = 1'b1;
                end

                // Above the range
                4'd4: val = 3'd6;

                // Equal bounds and zero delta: matching value
                4'd5: begin
                    low = 3'd4;
                    high = 3'd4;
                    delta = 3'd0;
                    val = 3'd4;
                    expected_range = 1'b1;
                    expected_offset = 1'b1;
                end

                // Equal bounds and zero delta: nonmatching value
                4'd6: begin
                    low = 3'd4;
                    high = 3'd4;
                    delta = 3'd0;
                    val = 3'd5;
                end

                // Reversed bounds; OffsetCheck overflows to high=1
                4'd7: begin
                    low = 3'd6;
                    high = 3'd1;
                    delta = 3'd3;
                    val = 3'd6;
                end

                // Full range, including the maximum input
                4'd8: begin
                    low = 3'd0;
                    high = 3'd7;
                    delta = 3'd7;
                    val = 3'd7;
                    expected_range = 1'b1;
                    expected_offset = 1'b1;
                end
            endcase

            #1;

            if (range_result !== expected_range) begin
                errors = errors + 16'd1;
                $display(
                    "ERROR: RangeCheck test=%d val=%d low=%d high=%d",
                    test_num, val, low, high
                );
                $display(
                    "Expected=%b Actual=%b",
                    expected_range, range_result
                );
            end

            if (offset_result !== expected_offset) begin
                errors = errors + 16'd1;
                $display(
                    "ERROR: OffsetCheck test=%d val=%d low=%d delta=%d",
                    test_num, val, low, delta
                );
                $display(
                    "Expected=%b Actual=%b",
                    expected_offset, offset_result
                );
            end
        end

        if (errors == 16'd0)
            $display("PASS: All 9 tests for each module passed");
        else
            $display("FAIL: %d failed checks", errors);

        $finish;
    end

endmodule