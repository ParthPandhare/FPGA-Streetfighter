module nes_controller(
    input nes_clock,        // 1MHz clock, divide in top level module
    input nes_data, 
    output logic nes_latch, 
    output logic a,
    output logic b,
    output logic start,
    output logic select,
    output logic up,
    output logic down,
    output logic left,
    output logic right
);    

    // divide the NES clock here to determine when to pulse the latch :)
    // polling clock speed should be 80kHz
    logic polling_clock;
    clock_divider #(1000000) polling_clock_(nes_clock, 80000, 0, polling_clock);

    logic [1:0] polling_clock_sr = 2'b00; 

    logic reading = 0;
    logic [2:0] read_count = 0; 

    logic [7:0] controls_read = 8'b00000000;
    logic read_toggle = 0;

    always @(posedge nes_clock) begin
        // capture the edge of the polling clock
        polling_clock_sr <= { polling_clock_sr[0], polling_clock };
        
        // if it's time to poll (i.e. if the polling clock has a posedge),
        // raise LATCH
        if (polling_clock_sr == 2'b01) begin
            nes_latch <= 1;
            read_toggle <= ~read_toggle;
        end
        // otherwise, lower LATCH and enable DATA reading
        else begin
            if (nes_latch == 1) begin
                reading <= 1;
            end
            nes_latch <= 0;
        end
        
        // if we're supposed to read from the controller (i.e. 8 bits
        // not yet consumed), do so and increment the read count
        if (reading) begin
            read_count <= read_count + 1;

            if (read_toggle) begin
                controls_read[read_count] <= nes_data;
            end

            if (read_count == 7) begin
                reading <= 0;
            end
        end

    end

    always_comb begin

        // single button presses
        if (controls_read == 8'b11111110) begin
            a = 1;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b11111100) begin
            a = 0;
            b = 1;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b11111001) begin
            a = 0;
            b = 0;
            start = 0;
            select = 1;
            up = 0;
            down = 0;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b11110011) begin
            a = 0;
            b = 0;
            start = 1;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b11100111) begin
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b11001111) begin
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 1;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b10011111) begin
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b00111111) begin
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 1;
        end

        // 2-button presses
        else if (controls_read == 8'b10001111) begin             // down + left
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 1;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b00001111) begin    // down + right
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 1;
            left = 0;
            right = 1;
        end else if (controls_read == 8'b10000111) begin    // up + left
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b00100111) begin    // up + right
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 0;
            right = 1;
        end else if (controls_read == 8'b10011100) begin    // left + b
            a = 0;
            b = 1;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b10011110) begin    // left + a
            a = 1;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b00111100) begin    // right + b
            a = 0;
            b = 1;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 1;
        end else if (controls_read == 8'b00111110) begin    // right + a
            a = 1;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 1;
        end else if (controls_read == 8'b11100100) begin    // up + b
            a = 0;
            b = 1;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 0;
            right = 0;
        end else if (controls_read == 8'b11100110) begin    // up + a
            a = 1;
            b = 0;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 0;
            right = 0;
        end

        // 3 button presses
        else if (controls_read == 8'b10000100) begin            // up + left + b
            a = 0;
            b = 1;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b00100100) begin    // up + right + b
            a = 0;
            b = 1;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 0;
            right = 1;
        end else if (controls_read == 8'b10000110) begin    // up + left + a
            a = 1;
            b = 0;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 1;
            right = 0;
        end else if (controls_read == 8'b00100110) begin    // up + right + a
            a = 1;
            b = 0;
            start = 0;
            select = 0;
            up = 1;
            down = 0;
            left = 0;
            right = 1;
        end 

        else begin
            a = 0;
            b = 0;
            start = 0;
            select = 0;
            up = 0;
            down = 0;
            left = 0;
            right = 0;
        end

    end


endmodule