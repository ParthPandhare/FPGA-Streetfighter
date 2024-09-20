`timescale 1ns/1ns

module game_top(
    input clk,
    input reset,
    input nes_data_one,
    input nes_data_two,
    output hsync,
    output vsync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue,
    output nes_latch_one, 
    output nes_latch_two,
    output nes_clk_one, 
    output nes_clk_two,
    output [9:0] leds
);


    logic vga_clk;
    clock clk_(clk, vga_clk, nes_clk_one);
    logic player_clk = 0;

    assign nes_clk_two = nes_clk_one;

    logic [9:0] hc = 0;
    logic [9:0] vc = 0;

    logic [9:0] x = 0;
    logic [9:0] y = 0;
    assign x = hc / 5;
    assign y = vc / 5;

    reg [7:0] color;
    reg [13:0] addr;
    reg [7:0] vga_color;
    logic [2:0] game_over;

	graphics graphics_(
        .x(x), 
        .y(y), 

        .player_one_x(player_one_x), 
        .player_one_y(player_one_y), 
        .player_one_state(player_one_state), 
        .player_one_health(player_one_health),
        .fireball_one_x(fireball_one_x),
        .fireball_one_y(fireball_one_y),
        .fireball_one_state(fireball_one_state),

        .player_two_x(player_two_x), 
        .player_two_y(player_two_y), 
        .player_two_state(player_two_state), 
        .player_two_health(player_two_health),
        .fireball_two_x(fireball_two_x),
        .fireball_two_y(fireball_two_y),
        .fireball_two_state(fireball_two_state),
        .game_over(game_over),

        .data_out(color), 
        .addr_out(addr)
    ); 

    ping_pong_ram ram_(
        .clk(vga_clk), 
        .addr_write(addr), 
        .addr_read_h(hc), 
        .addr_read_v(vc), 
        .data_write(color), 
        .data_read_out(vga_color), 
        .player_clk(player_clk)
    );

    vga vga_(
        .vgaclk(vga_clk), 
        .input_red(vga_color[7:5]), 
        .input_green(vga_color[4:2]), 
        .input_blue(vga_color[1:0]), 
        .rst(~reset), 
        .hc_out(hc), 
        .vc_out(vc), 
        .hsync(hsync), 
        .vsync(vsync), 
        .red(red), 
        .green(green), 
        .blue(blue)
    );


    // nes controller stuff

    logic a_one, b_one, start_one, select_one, up_one, down_one, left_one, right_one;
    logic a_two, b_two, start_two, select_two, up_two, down_two, left_two, right_two;

    nes_controller nc_one_(
        .nes_clock(nes_clk_one), 
        .nes_data(nes_data_one), 
        .nes_latch(nes_latch_one), 
        .a(a_one), 
        .b(b_one), 
        .start(start_one), 
        .select(select_one), 
        .up(up_one), 
        .down(down_one), 
        .left(left_one), 
        .right(right_one)
    );

    nes_controller nc_two_(
        .nes_clock(nes_clk_two), 
        .nes_data(nes_data_two), 
        .nes_latch(nes_latch_two), 
        .a(a_two), 
        .b(b_two), 
        .start(start_two), 
        .select(select_two), 
        .up(up_two), 
        .down(down_two), 
        .left(left_two), 
        .right(right_two)
    );
    
    // assign leds = { 2'b00, right_one, left_one, down_one, up_one, select_one, start_one, b_one, a_one };


    // player one

    logic [9:0] player_one_x = 10'd10;
    logic [9:0] player_one_y = 10'd70;
    logic [2:0] player_one_state = 3'd0;
    logic player_one_hit = 0;

    player player_one_(
        .clk(player_clk), 
        .start(start_one), 
        .left(left_one),  
        .right(right_one), 
        .up(up_one), 
        .down(down_one), 
        .a(a_one), 
        .b(b_one), 
        .player_number(1),
        .x(player_one_x), 
        .y(player_one_y), 
        .state(player_one_state), 
        .fireball_enable(fireball_one_enable), 
        .direction(player_one_direction),
        .opponent_fireball(player_one_hit)
    );


    // player one fireball

    logic [9:0] fireball_one_x = 10'd0;
    logic [9:0] fireball_one_y = 10'd0;
    logic [1:0] fireball_one_state = 2'b00;
    logic fireball_one_enable = 0;
    logic player_one_direction = 0;

    fireball fireball_one_(
        .clk(player_clk), 
        .start(start_one),
        .enabled(fireball_one_enable), 
        .direction(player_one_direction),
        .start_x(player_one_x),
        .start_y(player_one_y),
        .state(fireball_one_state),
        .x(fireball_one_x),
        .y(fireball_one_y),
        .opponent_hit(player_two_hit),
        .opponent_x(player_two_x),
        .opponent_y(player_two_y)
    );


    // player two

    logic [9:0] player_two_x = 10'd10;
    logic [9:0] player_two_y = 10'd70;
    logic [2:0] player_two_state = 3'd0;
    logic player_two_hit = 0;

    player player_two_(
        .clk(player_clk), 
        .start(start_two),      // TODO: CHANGE THIS TO START 2 OR SMTHING IDK 
        .left(left_two),  
        .right(right_two), 
        .up(up_two), 
        .down(down_two), 
        .a(a_two), 
        .b(b_two), 
        .player_number(0),
        .x(player_two_x), 
        .y(player_two_y), 
        .state(player_two_state), 
        .fireball_enable(fireball_two_enable), 
        .direction(player_two_direction),
        .opponent_fireball(player_two_hit)
    );


    // player two fireball

    logic [9:0] fireball_two_x = 10'd0;
    logic [9:0] fireball_two_y = 10'd0;
    logic [1:0] fireball_two_state = 2'b00;
    logic fireball_two_enable = 0;
    logic player_two_direction = 0;

    fireball fireball_two_(
        .clk(player_clk), 
        .start(start_one),      // TODO: CHANGE THIS TO START 2 OR SMTHING IDK
        .enabled(fireball_two_enable), 
        .direction(player_two_direction),
        .start_x(player_two_x),
        .start_y(player_two_y),
        .state(fireball_two_state),
        .x(fireball_two_x),
        .y(fireball_two_y),
        .opponent_hit(player_one_hit),
        .opponent_x(player_one_x),
        .opponent_y(player_one_y)
    );


    logic [6:0] player_one_health;
    logic [6:0] player_two_health;

    
    // COLLISION DETECTION
    game_handler game_handler_(
        .clk(clk),
        .player_one_x(player_one_x),
        .player_one_y(player_one_y),
        .player_one_state(player_one_state),
        .fireball_one_x(fireball_one_x),
        .fireball_one_y(fireball_one_y),
        .player_two_x(player_two_x),
        .player_two_y(player_two_y),
        .player_two_state(player_two_state),
        .fireball_two_x(fireball_two_x),
        .fireball_two_y(fireball_two_y),
        .player_two_hit(player_two_hit),
        .player_one_hit(player_one_hit),
        .player_one_direction(player_one_direction),
        .player_two_direction(player_two_direction),
        .player_one_health(player_one_health),
        .player_two_health(player_two_health),
        .player_one_reset(player_one_start),
        .player_two_reset(player_two_start),
        .game_over(game_over)
    );


endmodule