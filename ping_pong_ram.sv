module ping_pong_ram(
    input clk,
    input [13:0] addr_write,
    input [9:0] addr_read_h,
    input [9:0] addr_read_v,
    input [7:0] data_write,
    output reg [7:0] data_read_out,
    output player_clk
);	 
    logic [7:0] out_a;
    logic [13:0] addr_a;

    logic [7:0] out_b;
    logic [13:0] addr_b;

    logic write_enable = 0;
    logic [13:0] addr_read;

    ram memory_a(addr_a, clk, data_write, ~write_enable, out_a);
    ram memory_b(addr_b, clk, data_write, write_enable, out_b);

    always_ff @(posedge clk) begin

        if (addr_read_h == 10'd0 && addr_read_v == 10'd0) begin
            write_enable <= ~write_enable;
            player_clk <= 1;
        end

        if (player_clk == 1) begin
            player_clk <= 0;
        end

    end

    assign addr_read = (addr_read_h/5) + 128*(addr_read_v/5);
    assign addr_a = (write_enable) ? addr_read : addr_write;
    assign addr_b = (write_enable) ? addr_write : addr_read;
    assign data_read_out = (write_enable) ? out_a : out_b;

    /* SAME AS ABOVE BUT WITH REGISTER ARRAYS INSTEAD OF RAM FOR TESTING */
    // logic write_enable = 0;
    // logic [13:0] addr_read;

    // logic [1:0] memory_a [0:12287];
    // logic [1:0] memory_b [0:12287];


    // always @(posedge clk) begin

    //     if (addr_read_h == 10'd0 && addr_read_v == 10'd0) begin
    //         write_enable <= ~write_enable;
    //     end

    //     if (write_enable) begin
    //         memory_b[addr_write] <= data_write[7:6];
    //     end else begin
    //         memory_a[addr_write] <= data_write[7:6];
    //     end

    // end

    // assign addr_read = (addr_read_h / 5) + 128 * (addr_read_v / 5);

    // always_comb begin 
    //     if (write_enable) begin
    //         data_read_out = memory_a[addr_read];
    //     end else begin
    //         data_read_out = memory_b[addr_read];
    //     end
    // end
    
    /* ALSO FOR TESTING */
    // assign data_read_out = data_write;

endmodule