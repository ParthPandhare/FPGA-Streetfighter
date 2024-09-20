`timescale 1ns/1ns

module player_tb(
    output reg [9:0] x,
    output reg [9:0] fireball_x,
    output reg [9:0] y,
    output reg [9:0] fireball_y,
    output reg [2:0] state,
    output reg [1:0] fireball_state,

    output reg [9:0] two_x,
    output reg [9:0] two_fireball_x,
    output reg [9:0] two_y,
    output reg [9:0] two_fireball_y,
    output reg [2:0] two_state,
    output reg [1:0] two_fireball_state
);
    logic clk = 0;
    logic start = 0;
    logic left = 0;
    logic right = 0;
    logic up = 0;
    logic down = 0;
    logic a = 0;
    logic b = 0;
    logic fireball_enable = 0;
    logic fireball_direction = 0;
    logic one_hit = 0;

    player uut_1(
        .clk(clk), 
        .start(start),
        .left(left),  
        .right(right), 
        .up(up), 
        .down(down), 
        .a(a), 
        .b(b), 
        .x(x), 
        .y(y), 
        .state(state), 
        .fireball_enable(fireball_enable), 
        .direction(fireball_direction),
        .opponent_fireball(one_hit)
    );

    logic two_left = 0;
    logic two_right = 0;
    logic two_up = 0;
    logic two_down = 0;
    logic two_a = 0;
    logic two_b = 0;
    logic two_fireball_enable = 0;
    logic two_fireball_direction = 0;
    logic two_hit = 0;

    player uut_2(
        .clk(clk), 
        .start(start),
        .left(two_left),  
        .right(two_right), 
        .up(two_up), 
        .down(two_down), 
        .a(two_a), 
        .b(two_b), 
        .x(two_x), 
        .y(two_y), 
        .state(two_state), 
        .fireball_enable(two_fireball_enable), 
        .direction(two_fireball_direction),
        .opponent_fireball(two_hit)
    );

    fireball fireball_uut_1(
        .clk(clk), 
        .start(start),
        .enabled(fireball_enable), 
        .direction(fireball_direction),
        .start_x(x),
        .start_y(y),
        .state(fireball_state),
        .x(fireball_x),
        .y(fireball_y),
        .opponent_x(two_x),
        .opponent_y(two_y),
        .opponent_hit(two_hit)
    );

    fireball fireball_uut_2(
        .clk(clk), 
        .start(start),
        .enabled(two_fireball_enable), 
        .direction(two_fireball_direction),
        .start_x(two_x),
        .start_y(two_y),
        .state(two_fireball_state),
        .x(two_fireball_x),
        .y(two_fireball_y),
        .opponent_x(x),
        .opponent_y(y),
        .opponent_hit(one_hit)
    );

    always begin
        clk = ~clk;
        #5;
    end

endmodule