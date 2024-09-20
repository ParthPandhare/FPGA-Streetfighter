module nes_controller_top(
    input clk, 
    input nes_data, 
    output nes_latch, 
    output nes_clock, 
    output [9:0] leds
);

    logic temp_clk;
    clock data_clk_(clk, temp_clk, nes_clock); // 1 MHz
    
    logic a, b, start, select, up, down, left, right;
    nes_controller nc(nes_clock, nes_data, nes_latch, a, b, start, select, up, down, left, right);
    
    assign leds = { 2'b00, right, left, down, up, select, start, b, a };
    
endmodule