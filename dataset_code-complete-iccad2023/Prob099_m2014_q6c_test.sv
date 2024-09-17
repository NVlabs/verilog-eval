`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13



module stimulus_gen (
	input clk,
	output logic[6:1] y,
	output logic w,
	input tb_match
);

	initial begin
		// Test the one-hot cases first.
		repeat(200) @(posedge clk, negedge clk) begin
			y <= 1<< ($unsigned($random) % 6);
			w <= $random;
		end	
	
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_Y2;
		int errortime_Y2;
		int errors_Y4;
		int errortime_Y4;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [6:1] y;
	logic w;
	logic Y2_ref;
	logic Y2_dut;
	logic Y4_ref;
	logic Y4_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,y,w,Y2_ref,Y2_dut,Y4_ref,Y4_dut );
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
		.Y2(Y2_ref),
		.Y4(Y4_ref) );
		
	TopModule top_module1 (
		.y,
		.w,
		.Y2(Y2_dut),
		.Y4(Y4_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_Y2) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Y2", stats1.errors_Y2, stats1.errortime_Y2);
		else $display("Hint: Output '%s' has no mismatches.", "Y2");
		if (stats1.errors_Y4) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Y4", stats1.errors_Y4, stats1.errortime_Y4);
		else $display("Hint: Output '%s' has no mismatches.", "Y4");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { Y2_ref, Y4_ref } === ( { Y2_ref, Y4_ref } ^ { Y2_dut, Y4_dut } ^ { Y2_ref, Y4_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (Y2_ref !== ( Y2_ref ^ Y2_dut ^ Y2_ref ))
		begin if (stats1.errors_Y2 == 0) stats1.errortime_Y2 = $time;
			stats1.errors_Y2 = stats1.errors_Y2+1'b1; end
		if (Y4_ref !== ( Y4_ref ^ Y4_dut ^ Y4_ref ))
		begin if (stats1.errors_Y4 == 0) stats1.errortime_Y4 = $time;
			stats1.errors_Y4 = stats1.errors_Y4+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule



