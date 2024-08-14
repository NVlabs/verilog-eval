`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic resetn,
	output logic x, y
);

	initial begin
		resetn = 0;
		x = 0;
		y = 0;
		@(posedge clk);
		@(posedge clk);
		resetn = 1;
		repeat(500) @(negedge clk) begin
			resetn <= ($random & 31) != 0;
			{x,y} <= $random;
		end
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_f;
		int errortime_f;
		int errors_g;
		int errortime_g;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic resetn;
	logic x;
	logic y;
	logic f_ref;
	logic f_dut;
	logic g_ref;
	logic g_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,resetn,x,y,f_ref,f_dut,g_ref,g_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.resetn,
		.x,
		.y );
	RefModule good1 (
		.clk,
		.resetn,
		.x,
		.y,
		.f(f_ref),
		.g(g_ref) );
		
	TopModule top_module1 (
		.clk,
		.resetn,
		.x,
		.y,
		.f(f_dut),
		.g(g_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_f) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "f", stats1.errors_f, stats1.errortime_f);
		else $display("Hint: Output '%s' has no mismatches.", "f");
		if (stats1.errors_g) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "g", stats1.errors_g, stats1.errortime_g);
		else $display("Hint: Output '%s' has no mismatches.", "g");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { f_ref, g_ref } === ( { f_ref, g_ref } ^ { f_dut, g_dut } ^ { f_ref, g_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (f_ref !== ( f_ref ^ f_dut ^ f_ref ))
		begin if (stats1.errors_f == 0) stats1.errortime_f = $time;
			stats1.errors_f = stats1.errors_f+1'b1; end
		if (g_ref !== ( g_ref ^ g_dut ^ g_ref ))
		begin if (stats1.errors_g == 0) stats1.errortime_g = $time;
			stats1.errors_g = stats1.errors_g+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

