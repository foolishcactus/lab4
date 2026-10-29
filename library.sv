//`default_nettype none

module Comparator #(parameter WIDTH = 3) (
    input  logic [WIDTH-1:0] A, B,
    output logic AeqB
);
    assign AeqB = (A == B);
endmodule

module MagComp #(parameter WIDTH = 3) (
    input  logic [WIDTH-1:0] A, B,
    output logic AgtB, AeqB, AltB
);
    assign AgtB = (A > B);
    assign AeqB = (A == B);
    assign AltB = (A < B);
endmodule

module Adder #(parameter WIDTH = 3) (
    input  logic cin,
    input  logic [WIDTH-1:0] A, B,
    output logic [WIDTH-1:0] sum,
    output logic cout
);
    assign {cout, sum} = {1'b0, A} + {1'b0, B} + cin;
endmodule

module Subtracter #(parameter WIDTH = 3) (
    input  logic bin,
    input  logic [WIDTH-1:0] A, B,
    output logic [WIDTH-1:0] diff,
    output logic bout
);
    assign {bout, diff} = {1'b0, A} - {1'b0, B} - bin;
endmodule

module Multiplexer #(parameter WIDTH = 3) (
    input  logic [WIDTH-1:0] I,
    input  logic [$clog2(WIDTH)-1:0] S,
    output logic Y
);
    assign Y = I[S];
endmodule

module Mux2to1 #(parameter WIDTH = 3) (
    input  logic [WIDTH-1:0] I0, I1,
    input  logic S,
    output logic [WIDTH-1:0] Y
);
    assign Y = S ? I1 : I0;
endmodule

module Decoder #(parameter WIDTH = 3) (
    input  logic [$clog2(WIDTH)-1:0] I,
    input  logic en,
    output logic [WIDTH-1:0] D
);
    always_comb begin
        D = '0;
        if (en && (I < WIDTH))
            D[I] = 1'b1;
    end
endmodule

module DFlipFlop (
    input  logic D, clock, preset_L, reset_L,
    output logic Q
);
    always_ff @(posedge clock or negedge preset_L or negedge reset_L) begin
        if (!reset_L)
            Q <= 1'b0;
        else if (!preset_L)
            Q <= 1'b1;
        else
            Q <= D;
    end
endmodule

module Register #(parameter WIDTH = 3) (
    input  logic en, clear,
    input  logic [WIDTH-1:0] D,
    input  logic clock,
    output logic [WIDTH-1:0] Q
);
    always_ff @(posedge clock) begin
        if (en)
            Q <= D;
        else if (clear)
            Q <= '0;
    end
endmodule

module Counter #(parameter WIDTH = 3) (
    input  logic en, clear, load, up,
    input  logic [WIDTH-1:0] D,
    input  logic clock,
    output logic [WIDTH-1:0] Q
);
    always_ff @(posedge clock) begin
        if (clear)
            Q <= '0;
        else if (load)
            Q <= D;
        else if (en) begin
            if (up)
                Q <= Q + 1'b1;
            else
                Q <= Q - 1'b1;
        end
    end
endmodule

module ShiftRegisterSIPO #(parameter WIDTH = 3) (
    input  logic en, left, serial, clock,
    output logic [WIDTH-1:0] Q
);
    always_ff @(posedge clock) begin
      if (en) begin
        if (left)
            Q <= {Q[WIDTH-2:0], serial};
        else
            Q <= {serial, Q[WIDTH-1:1]};
      end
  end
endmodule

module ShiftRegisterPIPO #(parameter WIDTH = 3) (
    input  logic en, left, load,
    input  logic [WIDTH-1:0] D,
    input  logic clock,
    output logic [WIDTH-1:0] Q
);
    always_ff @(posedge clock) begin
        if (load)
            Q <= D;
        else if (en) begin
            if (left)
                Q <= Q << 1;
            else
                Q <= Q >> 1;
        end
    end
endmodule

module BarrelShiftRegister #(parameter WIDTH = 3) (
    input  logic en, load,
    input  logic [1:0] by,
    input  logic [WIDTH-1:0] D,
    input  logic clock,
    output logic [WIDTH-1:0] Q
);
    always_ff @(posedge clock) begin
        if (load)
            Q <= D;
        else if (en)
            Q <= Q << by;
    end
endmodule

module Synchronizer (
    input  logic async, clock,
    output logic sync
);
    logic stage1;
    always_ff @(posedge clock) begin
        stage1 <= async;
        sync <= stage1;
    end
endmodule

module BusDriver #(parameter WIDTH = 3) (
    input  logic en,
    input  logic [WIDTH-1:0] data,
    output logic [WIDTH-1:0] buff,
    inout  wire  [WIDTH-1:0] bus
);
    assign buff = data;
    assign bus = en ? buff : {WIDTH{1'bz}};
endmodule

module Memory #(parameter AW = 4, DW = 8) (
    input  logic [AW-1:0] addr,
    input  logic re, we, clock,
    inout  wire  [DW-1:0] data
);
    logic [DW-1:0] mem [0:(1<<AW)-1];
    assign data = (re && !we) ? mem[addr] : {DW{1'bz}};
    always_ff @(posedge clock) begin
        if (we)
            mem[addr] <= data;
    end
endmodule

module RangeCheck #(parameter WIDTH = 3) (
    input  logic [WIDTH-1:0] val, low, high,
    output logic is_between
);
    assign is_between = (val >= low) && (val <= high);
endmodule

module OffsetCheck #(parameter WIDTH = 3) (
    input  logic [WIDTH-1:0] val, low, delta,
    output logic is_between
);
    logic [WIDTH-1:0] high;
    logic cout;

    Adder #(WIDTH) a1 (
        .cin(1'b0),
        .A(low),
        .B(delta),
        .sum(high),
        .cout(cout)
    );

    RangeCheck #(WIDTH) r1 (
        .val(val),
        .low(low),
        .high(high),
        .is_between(is_between)
    );
endmodule