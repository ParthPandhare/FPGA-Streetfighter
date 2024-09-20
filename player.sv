module player(
    input clk,
    input start,
    input left,
    input right,
    input up,
    input down,
    input a,
    input b,
    input opponent_fireball,     // other player's fireball
    input player_number,

    output reg [9:0] x,
    output reg [9:0] y,
    output reg [2:0] state,

    // fireball outputs
    output reg fireball_enable,
    output reg direction        // 0 means facing left, 1 means facing right
);
    `include "globals.svh"

    logic [2:0] state_d = 3'd0;

    logic [9:0] x_d = 10'd10;
    logic [9:0] y_d = GROUND_LEVEL;

    logic [5:0] y_velocity = 6'd0;      // { upwards velocity, downwards velocity }
    logic [5:0] y_velocity_d = 6'd0;

    logic [1:0] direction_d = 2'b00;

    logic [1:0] crouch_state_counter = 2'b0;

    logic [1:0] b_sr = 2'b0;
    logic [3:0] melee_cooldown_timer = 4'd0;


    always @(posedge clk) begin

        if (!start) begin
		  
            x <= x_d;
            y <= y_d;
            y_velocity <= y_velocity_d;
            state <= state_d;
            direction <= direction_d;
            crouch_state_counter <= crouch_state_counter + 1;

            b_sr = { b_sr[0], b };

            if (melee_cooldown_timer != 0 || state_d == MELEE_STATE_LEFT || state_d == MELEE_STATE_RIGHT) begin
                melee_cooldown_timer <= melee_cooldown_timer + 1;
            end

        end else begin
		  
            if (player_number) begin
                x <= 10'd10;
                direction <= 1;
            end else begin
                x <= 10'd107;
                direction <= 0;
            end 
            y <= GROUND_LEVEL;
            y_velocity <= 6'd0;
            state <= DEFAULT_STATE;
            crouch_state_counter <= 2'b0;

        end

    end

    always_comb begin

        if (opponent_fireball) begin

            x_d = x;
            y_d = y;
            direction_d = direction;
            y_velocity_d = y_velocity;
            state_d = HIT_STATE;


        end else if (melee_cooldown_timer != 0) begin    // melee attack cooldown

            x_d = x;
            y_d = y;
            direction_d = direction;
            y_velocity_d = y_velocity;

            if (direction)
                state_d = MELEE_STATE_RIGHT;
            else
                state_d = MELEE_STATE_LEFT;
            
        end else begin
    
            // LEFT & RIGHT MOVEMENT
            if (left && x > 1) begin
                if (state != CROUCH_STATE) begin
                    x_d = x - 1;
                end else begin
                    x_d = x - (!crouch_state_counter);
                end

                direction_d = LEFT;
            end else if (right && x < 127) begin
                if (state != CROUCH_STATE) begin
                    x_d = x + 1;
                end else begin
                    x_d = x + (!crouch_state_counter);
                end

                direction_d = RIGHT;
            end else begin
                x_d = x;
                direction_d = direction;
            end

            // UP & DOWN MOVEMENT (JUMPING)
            if (up && y == GROUND_LEVEL) begin
                state_d = JUMP_STATE;
                y_velocity_d = { 3'd7, 3'b0 };
            end else if (y < GROUND_LEVEL) begin
                state_d = JUMP_STATE;
                if (y_velocity[2:0] == 3'b111) begin    // to prevent overflow (downwards velocity > 7)
                    if (y == 10'd63) begin
                        y_velocity_d = 6'd0;
                    end else begin
                        y_velocity_d = { 3'b0, 3'b111 };
                    end
                end else if (y_velocity[5:3] != 0) begin
                    y_velocity_d = { y_velocity[5:3] - 1, 3'b0 };
                end else begin
                    y_velocity_d = { 3'b0, y_velocity[2:0] + 1 };
                end
            end else begin
                y_velocity_d = 6'd0;
                state_d = DEFAULT_STATE;
            end 

            // UPDATING Y-POSITION
            if (y == GROUND_LEVEL && !up) begin
                y_d = y;
            end else if (y_velocity[5:3] != 3'd0) begin
                y_d = y - y_velocity[5:3];
            end else if (y_velocity[2:0] != 3'd0) begin
                y_d = y + y_velocity[2:0];
            end else begin
                y_d = y;
            end

            // CROUCHING & MELEE ATTACKS
            if (down && y == GROUND_LEVEL && !up) begin
                state_d = CROUCH_STATE;
            end else if (y < GROUND_LEVEL) begin
                state_d = JUMP_STATE;
            end else if (b_sr == 2'b01) begin
                if (direction)
                    state_d = MELEE_STATE_RIGHT;
                else 
                    state_d = MELEE_STATE_LEFT;
            end else begin
                state_d = DEFAULT_STATE;
            end

        end

    end

    assign fireball_enable = a;

endmodule