module Task1_tb;

  logic [3:0] val, low, high;
  logic[3:0] val2, low2, delta;
  logic is_between, is_between2;

  RangeCheck #(4) dut(
    .val(val), 
    .low(low), 
    .high(high),
    .is_between(is_between)
  );

  OffsetCheck #(4) dut2(
    .val(val2), 
    .low(low2), 
    .delta(delta),
    .is_between(is_between2)
  );

  initial begin
    val = 4'd5;
    low = 4'd3;
    high = 4'd6;

    #10
    //checks if 5 is >3 and <6
    if (!is_between)
        $display("ERROR 1: val=%d low=%d high=%d", val, low, high);
    
    val = 4'd10;
    low = 4'd3;
    high = 4'd6;
    #10

    //checks if 10 is >3 and <6
    if(is_between)
      $display("ERROR 2: val=%d low=%d high=%d", val, low, high);

    val = 4'd5;
    low = 4'd5;
    high = 4'd5;
    #10

    //checks if 5 is > 5 and < 5
    if(!is_between)
      $display("ERROR 3: val=%d low=%d high=%d", val, low, high);

    //checking offset checker
    val2 = 4'd5;
    low = 4'd5;
    delta = 4'd10;

    #10

    //checks if 5 is >5 <15
    if(!is_between2)
      $display("ERROR 4: val=%d low=%d high=%d", val2, low2, delta);

    val2 = 4'd5;
    low = 4'd1;
    delta = 4'd3;
    #10

    //checks if 5 is >1 and <4
    if(is_between2)
      $display("ERROR 5: val=%d low=%d high=%d", val2, low2, delta);

    val2 = 4'd5;
    low = 4'd1;
    delta = 4'd4;
    #10

    //checks if 5 is >1 and <5
    if(is_between2)
      $display("ERROR 6: val=%d low=%d high=%d", val2, low2, delta);
    
  end
    
endmodule