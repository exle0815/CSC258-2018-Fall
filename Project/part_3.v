// Part 2 skeleton

module part_3
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
	wire enable, ld_colour, ld_erase, counter_reset, control_delay;
	wire delay_frame, frame_control, count_x, count_y;
	wire [7:0] new_x;
	wire [6:0] new_y;
	wire [1:0] direction;

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
			.ld_colour(ld_colour),
			.ld_erase(ld_erase),
			.new_x(new_x),
			.new_y(new_y)
			);
    // Instansiate FSM control
    // control c0(...);
    control c0(
    		.resetn(resetn),
    		.clock(CLOCK_50),
    		.go_2(go2),
    		.frame_count(frame_control),
    		.count_x(count_x),
    		.count_y(count_y),
    		.ld_colour(ld_colour),
    		.ld_erase(ld_erase),
    		.counter_reset(counter_reset),
    		.direction(direction),
    		.enable(enable),
    		.wren(writeEn),
			.control_delay(control_delay)
    		);

    delay_counter c1(
    		.resetn(~counter_reset),
    		.clock(CLOCK_50),
    		.en(control_delay),
    		.q(delay_frame)
    		);

    frame_counter c2(
    		.resetn(~counter_reset),
    		.clock(CLOCK_50),
    		.en(delay_frame),
    		.q(frame_control)
    		);

    counter_x c3(
    		.resetn(resetn),
    		.clock(CLOCK_50),
    		.en(count_x),
    		.dir(direction),
    		.q(new_x)
    		);

    counter_y c4(
    		.resetn(resetn),
    		.clock(CLOCK_50),
    		.en(count_y),
    		.dir(direction),
    		.q(new_y)
    		);

endmodule

module control(
	input resetn,
	input clock,
	input go_2,
	input frame_count,
	output reg counter_reset,
	output reg direction, 
	output reg ld_erase,
	output reg ld_colour, 
	output reg enable,
	output reg wren,
	output reg count_x,
	output reg count_y,
	output reg control_delay
	);

	wire divider_to_control, en;
	assign en = ld_erase;

	reg [2:0] current_state, next_state;

	localparam  START  			= 3'd0,
			    START_WAIT 		= 3'd1,
			    S_CYCLE_0		= 3'd2,
			    S_CYCLE_1   	= 3'd3,
				S_CYCLE_2		= 3'd4;

	rate_divider r0(
			.clk(clock),
			.resetn(resetn),
			.en(en),
			.q(divider_to_control)
			);

	always @(*)
	begin: state_table
		case (current_state)
			START : next_state = go_2 ? START_WAIT : START;
			START_WAIT : next_state = go_2 ? START_WAIT : S_CYCLE_0;
			S_CYCLE_0: next_state = frame_count ? S_CYCLE_1 : S_CYCLE_0;
			S_CYCLE_1: next_state = divider_to_control ? S_CYCLE_2 : S_CYCLE_1;
			S_CYCLE_2: next_state = S_CYCLE_0;
			default: next_state = START;
		endcase
	end

	always @(*)
	begin: enable_signals
		direction = 2'b00;
		counter_reset = 1'b0;
		ld_colour = 1'b0;
		ld_erase = 1'b0;
		enable = 1'b0;
		wren = 1'b0;
		control_delay = 1'b0;
		count_x = 1'b0;
		count_y = 1'b0;

		case (current_state)
			S_CYCLE_0:
			begin
				ld_colour = 1'b1;
				enable = 1'b1;
				wren = 1'b1;
				control_delay = 1'b1;
				counter_reset = 1'b1;
				direction = 2'b01;
			end
			S_CYCLE_1:
			begin
				ld_erase = 1'b1;
				enable = 1'b1;
				wren = 1'b1;
				direction = 2'b01;
			end
			S_CYCLE_2:
			begin
				direction = 2'b01;
				count_x = 1'b1;
				count_y = 1'b1;
			end
		endcase
	end

	always @(posedge clock)
	begin: state_FFs
		if (~resetn)
			current_state <= START;
		else 
			current_state <= next_state;
	end

endmodule

module datapath(
	input resetn,
	input clock,
	input enable,
	input [7:0] new_x,
	input [6:0] new_y,
	input ld_x,
	input ld_y,
	input ld_colour,
	input ld_erase,
	output [7:0] x,
	output [6:0] y,
	output [2:0] colour
	);

	wire [3:0] counter_to_value;
	reg [2:0] colour_out;

	counter t0(
			.clk(clock),
			.en(enable),
			.resetn(resetn),
			.q(counter_to_value)
			);

	always @(posedge clock)
	begin
		if (~resetn)
			colour_out <= 3'b000;
		else
		begin
			if (ld_colour)
				colour_out <= 3'b100;
			if (ld_erase)
				colour_out <= 3'b000;
		end
	end
	assign x = new_x + counter_to_value[1:0];
	assign y = new_y + counter_to_value[3:2];
	assign colour = colour_out;
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

module delay_counter(
	input resetn,
	input clock,
	input en,
	output q
	);
	reg [19:0] out;

	always @(posedge clock)
	begin
		if (~resetn)
			out <= 20'b11001011011100110101;
		else if (en)
		begin 
			if (out == 20'b00000000000000000000)
				out <= 20'b11001011011100110101;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 20'b00000000000000000000) ? 1 : 0;

endmodule

module frame_counter(
	input resetn,
	input clock,
	input en,
	output q
	);
	reg [3:0] out;

	always @(posedge clock)
	begin
		if (~resetn)
			out <= 4'b1110;
		else if (en)
		begin 
			if (out == 4'b1110)
				out <= 4'b0000;
			else
			 	out <= out - 1'b1;
		end
	end
	assign q = (out == 4'b0000) ? 1 : 0;

endmodule

module counter_x(
	input resetn,
	input clock,
	input en,
	input dir,
	output reg [7:0] q
	);

	always @(posedge clock)
	begin
		if (~resetn)
			q <= 8'b00000000;
		else if (en)
		begin
			if (dir == 2)
			begin
				if (q == 8'b10100000)
					q <= 8'b00000000;
				else
					q <= q + 8'd4;
			end
		end
		else
			q <= q;
	end
endmodule

module counter_y(
	input resetn,
	input clock,
	input en,
	input dir,
	output reg [6:0] q
	);

	always @(posedge clock)
	begin
		if (~resetn)
			q <= 7'b00000000;
		else if (en)
		begin
			if (dir == 1)
			begin
				if (q == 7'b1111000)
					q <= 7'b0000000;
				else
					q <= q + 7'd4;
			end
		end
	end
endmodule