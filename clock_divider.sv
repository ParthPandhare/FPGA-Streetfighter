module clock_divider #(BASE_SPEED=50000000) (
	input clk,
	input [$clog2(1000000):0] speed,
	input reset_button,
	output reg outClk
);
	wire [$clog2(BASE_SPEED):0] max_value = (BASE_SPEED / speed) - 1;
	logic [$clog2(BASE_SPEED):0] counter = 0;

	// next clock cycle values:
	logic [$clog2(BASE_SPEED):0] counter_d;
	logic outClk_d;

	always_comb begin 
		if (reset_button || counter < (max_value + 1) / 2) begin
			outClk_d = 0;
		end
		else begin
			outClk_d = 1;
		end

		if (reset_button || counter == max_value) begin
			counter_d = 0;
		end
		else begin
			counter_d = counter + 1;
		end
	end

	always @(posedge clk) begin
		counter <= counter_d;
		outClk <= outClk_d;
	end


endmodule