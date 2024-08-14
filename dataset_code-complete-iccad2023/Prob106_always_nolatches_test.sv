`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic [15:0] scancode, 
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable	
);


// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	



	initial begin
		@(negedge clk) wavedrom_start("Recognize arrow keys");
			@(posedge clk) scancode <= 16'h0;
			@(posedge clk) scancode <= 16'h1;
			@(posedge clk) scancode <= 16'he075;
			@(posedge clk) scancode <= 16'he06b;
			@(posedge clk) scancode <= 16'he06c;
			@(posedge clk) scancode <= 16'he072;
			@(posedge clk) scancode <= 16'he074;
			@(posedge clk) scancode <= 16'he076;
			@(posedge clk) scancode <= 16'hffff;
		@(negedge clk) wavedrom_stop();

		repeat(30000) @(posedge clk, negedge clk) begin
			scancode <= $urandom;
		end
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_left;
		int errortime_left;
		int errors_down;
		int errortime_down;
		int errors_right;
		int errortime_right;
		int errors_up;
		int errortime_up;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [15:0] scancode;
	logic left_ref;
	logic left_dut;
	logic down_ref;
	logic down_dut;
	logic right_ref;
	logic right_dut;
	logic up_ref;
	logic up_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,scancode,left_ref,left_dut,down_ref,down_dut,right_ref,right_dut,up_ref,up_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.scancode );
	RefModule good1 (
		.scancode,
		.left(left_ref),
		.down(down_ref),
		.right(right_ref),
		.up(up_ref) );
		
	TopModule top_module1 (
		.scancode,
		.left(left_dut),
		.down(down_dut),
		.right(right_dut),
		.up(up_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_left) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "left", stats1.errors_left, stats1.errortime_left);
		else $display("Hint: Output '%s' has no mismatches.", "left");
		if (stats1.errors_down) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "down", stats1.errors_down, stats1.errortime_down);
		else $display("Hint: Output '%s' has no mismatches.", "down");
		if (stats1.errors_right) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "right", stats1.errors_right, stats1.errortime_right);
		else $display("Hint: Output '%s' has no mismatches.", "right");
		if (stats1.errors_up) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "up", stats1.errors_up, stats1.errortime_up);
		else $display("Hint: Output '%s' has no mismatches.", "up");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { left_ref, down_ref, right_ref, up_ref } === ( { left_ref, down_ref, right_ref, up_ref } ^ { left_dut, down_dut, right_dut, up_dut } ^ { left_ref, down_ref, right_ref, up_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (left_ref !== ( left_ref ^ left_dut ^ left_ref ))
		begin if (stats1.errors_left == 0) stats1.errortime_left = $time;
			stats1.errors_left = stats1.errors_left+1'b1; end
		if (down_ref !== ( down_ref ^ down_dut ^ down_ref ))
		begin if (stats1.errors_down == 0) stats1.errortime_down = $time;
			stats1.errors_down = stats1.errors_down+1'b1; end
		if (right_ref !== ( right_ref ^ right_dut ^ right_ref ))
		begin if (stats1.errors_right == 0) stats1.errortime_right = $time;
			stats1.errors_right = stats1.errors_right+1'b1; end
		if (up_ref !== ( up_ref ^ up_dut ^ up_ref ))
		begin if (stats1.errors_up == 0) stats1.errortime_up = $time;
			stats1.errors_up = stats1.errors_up+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

