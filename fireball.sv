module fireball(
    input clk,
    input start,    // basically reset as well
    input enabled,
    input direction,        // 0 for left, 1 for right
    input [9:0] start_x,
    input [9:0] start_y,

    input opponent_hit,
    input [9:0] opponent_x,
    input [9:0] opponent_y,

    output reg [1:0] state,
    output reg [9:0] x,
    output reg [9:0] y
);

    `include "globals.svh"

    logic [1:0] state_d = 2'b00;
    logic [1:0] enabled_sr = 2'b00;
    logic [4:0] explosion_counter = 5'd0;

    logic [9:0] x_d = 10'd0;
    logic [9:0] y_d = 10'd0;

    logic [1:0] opponent_hit_sr = 2'b00;

    always @(posedge clk) begin

        if (!start) begin
            state <= state_d;
            x <= x_d;
            y <= y_d;

            enabled_sr <= { enabled_sr[0], enabled };
            opponent_hit_sr <= { opponent_hit_sr[0], opponent_hit };

            if (state_d == FIREBALL_EXPLOSION || explosion_counter == 5'b11111) begin
                explosion_counter <= explosion_counter + 1;
            end
        end else begin
            state <= FIREBALL_DISABLED;
            x <= 0;
            y <= 0;

            enabled_sr <= 2'b00;
            explosion_counter <= 5'd0;
        end

    end

    always_comb begin

        if (opponent_hit_sr == 2'b01) begin

            state_d = FIREBALL_EXPLOSION;
            x_d = opponent_x;
            y_d = opponent_y - SPRITE_HEIGHT/2;

        end else if (enabled_sr == 2'b01 && state == FIREBALL_DISABLED) begin

            state_d = FIREBALL_ENABLED;

            if (direction == RIGHT) begin

                if (start_x == MAX_X || start_x == MAX_X - 1) begin
                    x_d = MAX_X;
                end else begin
                    x_d = start_x + 2;
                end

            end else begin

                x_d = start_x - 2;

            end

            y_d = start_y - 2;

        end else if (explosion_counter == 5'b11111) begin

            state_d = FIREBALL_DISABLED;
            x_d = 0;
            y_d = 0;

        end else if (state == FIREBALL_ENABLED) begin

            if (x >= start_x) begin

                if (x == MAX_X) begin
                    x_d = x;
                    state_d = FIREBALL_EXPLOSION;
                end else if (x == MAX_X - 1) begin
                    x_d = x + 1;
                    state_d = state;
                end else begin
                    x_d = x + 2;
                    state_d = state;
                end

            end else begin

                if (x == MIN_X) begin
                    x_d = x;
                    state_d = FIREBALL_EXPLOSION;
                end else if (x == MIN_X + 1) begin
                    x_d = x - 1;
                    state_d = state;
                end else begin
                    x_d = x - 2;
                    state_d = state;
                end

            end

            y_d = y;

        end else begin
            state_d = state;
            x_d = x;
            y_d = y;
        end

    end

endmodule











// module fireball(
//     input clk,
//     input start,    // basically reset as well
//     input enabled,
//     input direction,        // 0 for left, 1 for right
//     input [9:0] start_x,
//     input [9:0] start_y,

//     input [9:0] opponent_x,
//     input [9:0] opponent_y,

//     output reg [1:0] state,
//     output reg [9:0] x,
//     output reg [9:0] y,

//     output reg opponent_hit
// );

//     `include "globals.svh"

//     logic [1:0] state_d = 2'b00;
//     logic [1:0] enabled_sr = 2'b00;
//     logic [4:0] explosion_counter = 5'd0;

//     logic [9:0] x_d = 10'd0;
//     logic [9:0] y_d = 10'd0;

//     logic opponent_hit_d = 0;

//     always @(posedge clk) begin

//         if (!start) begin
//             state <= state_d;
//             x <= x_d;
//             y <= y_d;
//             opponent_hit <= opponent_hit_d;

//             enabled_sr <= { enabled_sr[0], enabled };

//             if (state_d == FIREBALL_EXPLOSION || explosion_counter == 5'b11111) begin
//                 explosion_counter <= explosion_counter + 1;
//             end
//         end else begin
//             state <= FIREBALL_DISABLED;
//             x <= 0;
//             y <= 0;
//             opponent_hit <= 0;

//             enabled_sr <= 2'b00;
//             explosion_counter <= 5'd0;
//         end

//     end

//     always_comb begin

//         if (enabled_sr == 2'b01 && state == FIREBALL_DISABLED) begin

//             state_d = FIREBALL_ENABLED;

//             if (direction == RIGHT) begin

//                 if (start_x == MAX_X || start_x == MAX_X - 1) begin
//                     x_d = MAX_X;
//                 end else begin
//                     x_d = start_x + 2;
//                 end

//             end else begin

//                 x_d = start_x - 2;

//             end

//             y_d = start_y - 2;
//             opponent_hit_d = 0;

//         end else if (explosion_counter == 5'b11111) begin

//             state_d = FIREBALL_DISABLED;
//             x_d = 0;
//             y_d = 0;
//             opponent_hit_d = 0;

//         end else if (state == FIREBALL_ENABLED) begin

//             if (opponent_x - SPRITE_WIDTH/2 <= x && x <= opponent_x + SPRITE_WIDTH/2 && 
//                 y >= opponent_y - SPRITE_HEIGHT + 1 && y <= opponent_y) begin
                
//                 x_d = x;
//                 state_d = FIREBALL_EXPLOSION;
//                 opponent_hit_d = 1;


//             end else if (x >= start_x) begin
//                 opponent_hit_d = 0;

//                 if (x != MAX_X) begin
//                     x_d = x + 1;
//                     state_d = state;
//                 end else begin
//                     x_d = x;
//                     state_d = FIREBALL_EXPLOSION;
//                 end 

//             end else begin
//                 opponent_hit_d = 0;

//                 if (x != MIN_X) begin
//                     x_d = x - 1;
//                     state_d = state;
//                 end else begin
//                     x_d = x;
//                     state_d = FIREBALL_EXPLOSION;
//                 end 

//             end

//             y_d = y;

//         end else begin
//             state_d = state;
//             x_d = x;
//             y_d = y;
//             opponent_hit_d = 0;
//         end

//     end

// endmodule