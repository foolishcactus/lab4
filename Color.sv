module Color (
  input logic ball, wall, paddle, brick, score;
  output logic red, green, blue;
)

//logic for determining when one item is high choose its relevant color
//always comb case statements detemrine color