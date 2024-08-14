`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic[5:0] y,
	output logic w,
	input tb_match
);

	int errored1 = 0;
	int onehot_error = 0;
	int temp;
	
	initial begin
		// Test the one-hot cases first.
		repeat(200) @(posedge clk, negedge clk) begin
			y <= 1<< ($unsigned($random) % 6);
			w <= $random;
			if (!tb_match) onehot_error++;
		end
			
			
		// Random.
		errored1 = 0;
		repeat(400) @(posedge clk, negedge clk) begin
			do 
				temp = $random;
			while ( !{temp[5:4],temp[2:1]} == !{temp[3],temp[0]} );	
			// Make y[3,0] and y[5,4,2,1] mutually exclusive, so we can accept Y3=(~y[3] & ~y[0]) &~w as a valid answer too.

			y <= temp;
			w <= $random;
			if (!tb_match)
				errored1++;
		end
		if (!onehot_error && errored1) 
			$display ("Hint: Your circuit passed when given only one-hot inputs, but not with semi-random inputs.");

		if (!onehot_error && errored1)
			$display("Hint: Are you doing something more complicated than deriving state transition equations by inspection?\n");

		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_Y1;
		int errortime_Y1;
		int errors_Y3;
		int errortime_Y3;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [5:0] y;
	logic w;
	logic Y1_ref;
	logic Y1_dut;
	logic Y3_ref;
	logic Y3_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,y,w,Y1_ref,Y1_dut,Y3_ref,Y3_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.y,
		.w );
	RefModule good1 (
		.y,
		.w,
		.Y1(Y1_ref),
		.Y3(Y3_ref) );
		
	TopModule top_module1 (
		.y,
		.w,
		.Y1(Y1_dut),
		.Y3(Y3_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_Y1) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Y1", stats1.errors_Y1, stats1.errortime_Y1);
		else $display("Hint: Output '%s' has no mismatches.", "Y1");
		if (stats1.errors_Y3) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Y3", stats1.errors_Y3, stats1.errortime_Y3);
		else $display("Hint: Output '%s' has no mismatches.", "Y3");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { Y1_ref, Y3_ref } === ( { Y1_ref, Y3_ref } ^ { Y1_dut, Y3_dut } ^ { Y1_ref, Y3_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (Y1_ref !== ( Y1_ref ^ Y1_dut ^ Y1_ref ))
		begin if (stats1.errors_Y1 == 0) stats1.errortime_Y1 = $time;
			stats1.errors_Y1 = stats1.errors_Y1+1'b1; end
		if (Y3_ref !== ( Y3_ref ^ Y3_dut ^ Y3_ref ))
		begin if (stats1.errors_Y3 == 0) stats1.errortime_Y3 = $time;
			stats1.errors_Y3 = stats1.errors_Y3+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

