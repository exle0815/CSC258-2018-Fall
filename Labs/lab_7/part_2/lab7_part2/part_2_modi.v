module part_2(CLOCK_50, SW, KEY);
	input	CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	wire resetn, go1, go2;
	assign resetn = KEY[0];
	assign go1 = ~KEY[3];
	assign go2 = ~KEY[1];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable, ld_x, ld_y, ld_colour, ld_r;

	datapath d0(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.enable(enable),
			.x(x),
			.y(y),
			.ld_x(ld_x),
			.ld_y(ld_y),
			.ld_colour(ld_colour),
			.ld_r(ld_r),
			.coord_in(SW[6:0]),
			.colour_in(SW[9:7])
			);
    // Instansiate FSM control
    // control c0(...);
    control c0(
    		.resetn(resetn),
    		.clock(CLOCK_50),
    		.go_1(go1),
    		.go_2(go2),
    		.ld_x(ld_x),
    		.ld_y(ld_y),
    		.ld_colour(ld_colour),
    		.ld_r(ld_r),
    		.enable(enable),
    		.wren(writeEn)
    		);
endmodule

module control(
	input resetn,
	input clock,
	input go_1,
	input go_2,
	output reg ld_x, 
	output reg ld_y, 
	output reg ld_colour, 
	output reg ld_r,
	output reg enable,
	output reg wren
	);

	wire divider_to_control, en;
	assign en = enable;

	reg [2:0] current_state, next_state;

	localparam  S_LOAD_X		= 3'd0,
			    S_LOAD_X_WAIT 	= 3'd1,
			    S_LOAD_Y		= 3'd2,
			    S_LOAD_Y_WAIT 	= 3'd3,
			    S_CYCLE_0 		= 3'd4,
			    S_CYCLE_1		= 3'd5;

	rate_divider r0(
			.clk(clock),
			.resetn(resetn),
			.en(en),
			.q(divider_to_control)
			);

	always @(*)
	begin: state_table
		case (current_state)
			S_LOAD_X: next_state = go_1 ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = go_1 ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state = go_2 ? S_LOAD_Y_WAIT : S_LOAD_Y;
			S_LOAD_Y_WAIT: next_state = go_2 ? S_LOAD_Y_WAIT : S_CYCLE_0;
			S_CYCLE_0: next_state = divider_to_control ? S_CYCLE_1 : S_CYCLE_0;	
			S_CYCLE_1: next_state = S_LOAD_X;
			default: next_state = S_LOAD_X;
		endcase
	end

	always @(*)
	begin: enable_signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_colour = 1'b0;
		ld_r = 1'b0;
		enable = 1'b0;
		wren = 1'b0;

		case (current_state)
			S_LOAD_X:
			begin
				ld_x = 1'b1;
			end
			S_LOAD_Y:
			begin
				ld_y = 1'b1;
			end
			S_CYCLE_0:
			begin
				ld_colour = 1'b1;
				enable = 1'b1;
				ld_r = 1'b1;
			end
			S_CYCLE_1:
			begin
				wren = 1'b1;
			end
		endcase
	end

	always @(posedge clock)
	begin: state_FFs
		if (~resetn)
			current_state <= S_LOAD_X;
		else 
			current_state <= next_state;
	end

endmodule

module datapath(
	input resetn,
	input clock,
	input enable,
	input [6:0] coord_in,
	input [2:0] colour_in,
	input ld_x,
	input ld_y,
	input ld_colour,
	input ld_r,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour
	);

	reg [7:0] x_data;
	reg [6:0] y_data;
	reg [2:0] colour_data;
	wire [3:0] counter_to_value;

	counter t0(
			.clk(clock),
			.en(enable),
			.resetn(resetn),
			.q(counter_to_value)
			);

	always @(posedge clock)
	begin
		if (~resetn)
		begin
			x_data <= 0;
			y_data <= 0;
			colour_data <= 0;
		end
		else
		begin
			if (ld_x)
				x_data <= {1'b0, coord_in};
			if (ld_y)
				y_data <= coord_in;
			if (ld_colour)
				colour <= colour_in;
			if (~ld_colour)
				colour <= 3'b0;
		end
	end

	always @ (posedge clock) 
		begin
	        if (~resetn) 
	        begin
	            x <= 8'b0;
	            y <= 7'b0;
	            colour <= 3'b0; 
	        end
	    	else
	        begin
	            if (ld_r)
	            begin
	                x <= x_data + counter_to_value[1:0];
	                y <= y_data + counter_to_value[3:2];
	            end
	            else
	            begin
	            	x <= 8'b0;
	            	y <= 7'b0;
	            end
	        end
	    end
endmodule

module counter(
	input clk,
	input resetn,
	input en,
	output reg [3:0] q
	);

	always @(posedge clk)
	begin
		if (~resetn)
			q <= 4'b0000;
		else if (en)
		begin
			if (q == 4'b1111)
				q <= 4'b0000;
			else
				q <= q + 1'b1;
		end
	end
endmodule

module rate_divider(
	input clk,
	input resetn,
	input en,
	output q
	);
	reg [4:0] out;

	always @(posedge clk)
	begin
		if (~resetn)
			out <= 5'b10000;
		else if (en)
		begin 
			if (out == 5'b00001)
				out <= 5'b10000;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 5'b00001) ? 1 : 0;
endmodule
