//`defaultnettype none

module Color (
    input logic ball, wall, paddle,
    input logic yellow_brick, purple_brick,
    input logic won, lost,

    output logic [7:0] red, green, blue
);

    always_comb begin
        red   = 8'h00;
        green = 8'h00;
        blue  = 8'h00;

        if (ball) begin
            red   = 8'hFF;
            green = 8'hFF;
            blue  = 8'hFF;
        end
        else if (paddle) begin
            green = 8'hFF;
        end
        else if (wall) begin
            if (lost)
                red = 8'hFF;
            else if (won)
                green = 8'hFF;
            else begin
                red   = 8'hCC;
                green = 8'hCC;
                blue  = 8'hCC;
            end
        end
        else if (yellow_brick) begin
            red   = 8'hFF;
            green = 8'hFF;
        end
        else if (purple_brick) begin
            red  = 8'hFF;
            blue = 8'hFF;
        end
    end
endmodule