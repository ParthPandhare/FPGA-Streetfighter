module game_handler (    
    input clk,
    input [9:0] player_one_x,
    input [9:0] player_one_y,
    input [2:0] player_one_state,
    input player_one_direction,
    input [9:0] fireball_one_x,
    input [9:0] fireball_one_y,
    input [9:0] player_two_x,
    input [9:0] player_two_y,
    input [2:0] player_two_state,
    input player_two_direction,
    input [9:0] fireball_two_x,
    input [9:0] fireball_two_y,
    input player_one_reset,
    input player_two_reset,
    output player_two_hit,
    output player_one_hit,
    output reg [6:0] player_one_health,
    output reg [6:0] player_two_health,
    output reg [1:0] game_over 
);
    `include "globals.svh"

    initial begin
        player_one_health = 7'd40;
        player_two_health = 7'd40;

        player_two_hit = 0;
        player_one_hit = 0;

        game_over = 2'b0;
    end


    // always @(posedge player_one_reset or posedge player_two_reset) begin

    //     if (player_one_health == 0 || player_one_health > 7'd40 || player_two_health == 0 || player_two_health > 7'd40) begin
    //         player_one_health <= 7'd40;
    //         player_two_health <= 7'd40;
    //     end

    // end


    always @(posedge player_one_hit) begin

        // if (((player_one_health - 5 == 7'd0 || player_one_health - 5 > 7'd40) && player_one_x - 5 <= fireball_two_x && fireball_two_x <= player_one_x + 5) || 
        //         (player_one_health - 2 == 7'd40 || player_one_health - 2 > 7'd40)) begin

        //     player_one_health <= 7'd40;
        //     game_over <= 2;
                    
        // end 
        if (player_one_x - 5 <= fireball_two_x && fireball_two_x <= player_one_x + 5) begin
            player_one_health <= player_one_health - 5;
        end else begin
            player_one_health <= player_one_health - 2;
        end

    end


    always @(posedge player_two_hit) begin

        if (player_two_x - 5 <= fireball_one_x && fireball_one_x <= player_two_x + 5) begin
            player_two_health <= player_two_health - 5;
        end else begin
            player_two_health <= player_two_health - 2;
        end

    end

    always_comb begin

        // checks whether player 2 is hit by player 1's melee attack
        if ((player_one_state == MELEE_STATE_RIGHT && player_two_y == player_one_y && player_one_x <= player_two_x && player_two_x <= player_one_x + SPRITE_WIDTH + 2)
            || (player_one_state == MELEE_STATE_LEFT && player_two_y == player_one_y && player_one_x - SPRITE_WIDTH - 2 <= player_two_x && player_two_x <= player_one_x)) begin
            
            player_two_hit = 1;

        // if the player is crouched, they can't be hit by a ranged attack
        end else if (player_two_state == CROUCH_STATE) begin

            player_two_hit = 0;

        // checks whether player 2 is hit by player 1's fireball
        end else if (player_two_x - SPRITE_WIDTH/2 - 1 <= fireball_one_x && fireball_one_x <= player_two_x + SPRITE_WIDTH/2 + 1 && 
                    fireball_one_y >= player_two_y - SPRITE_HEIGHT + 1 && fireball_one_y <= player_two_y) begin

            player_two_hit = 1;
            
        end else begin
            player_two_hit = 0;
        end



        // checks whether player 2 is hit by player 1's melee attack
        if ((player_two_state == MELEE_STATE_RIGHT && player_one_y == player_two_y && player_two_x <= player_one_x && player_one_x <= player_two_x + SPRITE_WIDTH + 2)
            || (player_two_state == MELEE_STATE_LEFT && player_one_y == player_two_y && player_two_x - SPRITE_WIDTH - 2 <= player_one_x && player_one_x <= player_two_x)) begin
            
            player_one_hit = 1;

        // if the player is crouched, they can't be hit by a ranged attack
        end else if (player_one_state == CROUCH_STATE) begin

            player_one_hit = 0;

        end else if (player_one_x - SPRITE_WIDTH/2 - 1 <= fireball_two_x && fireball_two_x <= player_one_x + SPRITE_WIDTH/2 + 1 && 
            fireball_two_y >= player_one_y - SPRITE_HEIGHT + 1 && fireball_two_y <= player_one_y) begin

            player_one_hit = 1;

        end else begin
            player_one_hit = 0;
        end

    end


endmodule