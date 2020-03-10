// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
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

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
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
			    S_CYCLE_0 		= 3'd4;

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
			S_CYCLE_0: next_state = divider_to_control ? S_LOAD_X : S_CYCLE_0;	
			default: next_state = S_LOAD_X;
		endcase
	end

	always @(*)
	begin: enable_signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_colour = 1'b0;
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
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
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
		end
	end
	assign x = x_data + counter_to_value[1:0];
	assign y = y_data + counter_to_value[3:2];
	assign colour = ld_colour ? colour_in : colour_data;
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

module simulation(
	input [6:0] coord_in,
	input [2:0] colour_in,
	input resetn,
	input clock,
	input go_1,
	input go_2,
	output[7:0] x,
	output[6:0] y,
	output[2:0] colour
	);
	
	wire enable,ld_x,ld_y,ld_colour,wren;
	
	control m1(resetn, clock, go_1, go_2, ld_x, ld_y, ld_colour, enable, wren);
	datapath m2(resetn, clock, enable, coord_in, colour_in, ld_x, ld_y, ld_colour, x, y, colour);
endmodule