module graphics(
    input [9:0] x,
    input [9:0] y,

    // player 1 stuff

    input [9:0] player_one_x,
    input [9:0] player_one_y,
    input [2:0] player_one_state,
    input [6:0] player_one_health,

    input [9:0] fireball_one_x,
    input [9:0] fireball_one_y,
    input [1:0] fireball_one_state,

    // player 2 stuff

    input [9:0] player_two_x,
    input [9:0] player_two_y,
    input [2:0] player_two_state,
    input [6:0] player_two_health,

    input [9:0] fireball_two_x,
    input [9:0] fireball_two_y,
    input [1:0] fireball_two_state,

    input [1:0] game_over,

    // color & coordinate on display

    output reg [7:0] data_out,
    output reg [13:0] addr_out

);

    `include "globals.svh"


    always_comb begin

        if (x < 128 && y < 96) begin

            // game over screens
            if (player_two_health == 0 || player_two_health > 7'd40) begin
                
                if (47 <= x && x < 80 && 39 <= y && y < 57) begin
                    
                    if (GAME_OVER_BITMAP[y - 39][x - 47]) begin
                        data_out = WHITE;
                    end else begin
                        data_out = BLACK;
                    end

                end else if (28 <= x && x < 100 && 72 <= y && y < 81) begin

                    if (64 <= x && x < 68) begin 

                        if (ONE_BITMAP[y - 72][x - 64]) begin
                            data_out = WHITE;
                        end else begin
                            data_out = BLACK;
                        end
                    
                    end else if (PLAYER_BLANK_WINS_BITMAP[y - 72][x - 28]) begin
                        data_out = WHITE;
                    end else begin
                        data_out = BLACK;
                    end

                end else begin
                    data_out = BLACK;
                end

            end else if (player_one_health == 0 || player_one_health > 7'd40) begin

                if (47 <= x && x < 80 && 39 <= y && y < 57) begin
                    
                    if (GAME_OVER_BITMAP[y - 39][x - 47]) begin
                        data_out = WHITE;
                    end else begin
                        data_out = BLACK;
                    end
                    
                end else if (28 <= x && x < 100 && 72 <= y && y < 81) begin

                    if (64 <= x && x < 68) begin 

                        if (TWO_BITMAP[y - 72][x - 64]) begin
                            data_out = WHITE;
                        end else begin
                            data_out = BLACK;
                        end
                    
                    end else if (PLAYER_BLANK_WINS_BITMAP[y - 72][x - 28]) begin
                        data_out = WHITE;
                    end else begin
                        data_out = BLACK;
                    end

                end else begin
                    data_out = BLACK;
                end

            // FIREBALL 1
            end else if (x == fireball_one_x && y == fireball_one_y) begin
                if (fireball_one_state == FIREBALL_ENABLED) begin
                    data_out = RED;
                end else if (fireball_one_state == FIREBALL_EXPLOSION) begin
                    data_out = ORANGE;
                end else begin
                    data_out = SKY_BLUE;
                end

            // FIREBALL 2
            end else if (x == fireball_two_x && y == fireball_two_y) begin
                if (fireball_two_state == FIREBALL_ENABLED) begin
                    data_out = RED;
                end else if (fireball_two_state == FIREBALL_EXPLOSION) begin
                    data_out = ORANGE;
                end else begin
                    data_out = SKY_BLUE;
                end

            // PLAYER 1
            end else if (x <= player_one_x + SPRITE_WIDTH/2 && x >= player_one_x - SPRITE_WIDTH/2 && 
                y >= player_one_y - SPRITE_HEIGHT + 1 && y <= player_one_y) begin

                data_out = SPRITE[player_one_state][y - (player_one_y - SPRITE_HEIGHT + 1)][x - player_one_x + 1];

            // PLAYER 2
            end else if (x <= player_two_x + SPRITE_WIDTH/2 && x >= player_two_x - SPRITE_WIDTH/2 && 
                y >= player_two_y - SPRITE_HEIGHT + 1 && y <= player_two_y) begin

                data_out = SPRITE[player_two_state][y - (player_two_y - SPRITE_HEIGHT + 1)][x - player_two_x + 1];

            end else if (y > GROUND_LEVEL) begin
                data_out = LIGHT_GREEN;
            end else if (y > 10 && y < 20 && x >= 10 && x < player_two_health + 10) begin
                data_out = RED;
            end else if (y > 10 && y < 20 && x >= 70 && x < player_one_health + 70) begin
                data_out = RED;
            end else begin
                data_out = SKY_BLUE;
            end

        end else begin
            data_out = 8'd0;
        end

    end

    assign addr_out = (x < 128 && y < 96) ? x + 128*y : 14'd0;

endmodule