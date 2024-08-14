`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg reset,
	output reg ena,
	input [7:0] hh_dut, mm_dut, ss_dut,
	input pm_dut,
	input tb_match,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable
);
	task reset_test(input async=0);
		bit arfail, srfail, datafail;
	
		@(posedge clk);
		@(posedge clk) reset <= 0;
		repeat(3) @(posedge clk);
	
		@(negedge clk) begin datafail = !tb_match ; reset <= 1; end
		@(posedge clk) arfail = !tb_match;
		@(posedge clk) begin
			srfail = !tb_match;
			reset <= 0;
		end
		if (srfail)
			$display("Hint: Your reset doesn't seem to be working.");
		else if (arfail && (async || !datafail))
			$display("Hint: Your reset should be %0s, but doesn't appear to be.", async ? "asynchronous" : "synchronous");
		// Don't warn about synchronous reset if the half-cycle before is already wrong. It's more likely
		// a functionality error than the reset being implemented asynchronously.
	
	endtask


// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	


	

	logic bcd_fail = 0;
	logic reset_fail = 0;
	
	always @(posedge clk) begin
		if ((hh_dut[3:0] >= 4'ha) ||
			(hh_dut[7:4] >= 4'ha) ||
			(mm_dut[3:0] >= 4'ha) ||
			(mm_dut[7:4] >= 4'ha) ||
			(ss_dut[3:0] >= 4'ha) ||
			(ss_dut[7:4] >= 4'ha))
			bcd_fail <= 1'b1;		
	end
	
	initial begin
		reset <= 1;
		ena <= 1;
		wavedrom_start("Reset and count to 10");
		reset_test();
		repeat(12) @(posedge clk);
		wavedrom_stop();
		ena <= 1'b1;
		reset <= 1'b1;
		@(posedge clk);
		@(posedge clk)
			if (!tb_match) begin
				$display("Hint: Clock seems to reset to %02x:%02x:%02x %s (Should be 12:00:00 AM).", hh_dut, mm_dut, ss_dut, pm_dut ? "PM": "AM");
				reset_fail <= 1'b1;
			end
		
		reset <= 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		ena <= 1'b0;
		reset <= 1'b1;
		@(posedge clk);
		@(posedge clk)
			if (!tb_match && !reset_fail)
				$display("Hint: Reset has higher priority than enable and should occur even if not enabled.");
		
		
		repeat(400) @(posedge clk, negedge clk) begin
			reset <= !($random & 31);
			ena <= !($random & 3);
		end
		reset <= 1;
		@(posedge clk) begin
			{reset, ena} <= 2'b1;
		end
		
		repeat(55) @(posedge clk);
		wavedrom_start("Minute roll-over");
		repeat(10) @(posedge clk);
		wavedrom_stop();

		repeat(3530) @(posedge clk);
		wavedrom_start("Hour roll-over");
		repeat(10) @(posedge clk);
		wavedrom_stop();


		repeat(39590) @(posedge clk);
		wavedrom_start("PM roll-over");
		repeat(10) @(posedge clk);
		wavedrom_stop();
		
		repeat(132745) @(posedge clk);
		repeat(50) @(posedge clk, negedge clk) begin
			ena <= !($random & 7);
		end
		reset <= 1'b1;
		repeat(5) @(posedge clk);
		
		
		if (bcd_fail)
			$display("Hint: Non-BCD values detected. Are you sure you're using two-digit BCD representation for hh, mm, and ss?");
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_pm;
		int errortime_pm;
		int errors_hh;
		int errortime_hh;
		int errors_mm;
		int errortime_mm;
		int errors_ss;
		int errortime_ss;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic reset;
	logic ena;
	logic pm_ref;
	logic pm_dut;
	logic [7:0] hh_ref;
	logic [7:0] hh_dut;
	logic [7:0] mm_ref;
	logic [7:0] mm_dut;
	logic [7:0] ss_ref;
	logic [7:0] ss_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,reset,ena,pm_ref,pm_dut,hh_ref,hh_dut,mm_ref,mm_dut,ss_ref,ss_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.reset,
		.ena );
	RefModule good1 (
		.clk,
		.reset,
		.ena,
		.pm(pm_ref),
		.hh(hh_ref),
		.mm(mm_ref),
		.ss(ss_ref) );
		
	TopModule top_module1 (
		.clk,
		.reset,
		.ena,
		.pm(pm_dut),
		.hh(hh_dut),
		.mm(mm_dut),
		.ss(ss_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_pm) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "pm", stats1.errors_pm, stats1.errortime_pm);
		else $display("Hint: Output '%s' has no mismatches.", "pm");
		if (stats1.errors_hh) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "hh", stats1.errors_hh, stats1.errortime_hh);
		else $display("Hint: Output '%s' has no mismatches.", "hh");
		if (stats1.errors_mm) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "mm", stats1.errors_mm, stats1.errortime_mm);
		else $display("Hint: Output '%s' has no mismatches.", "mm");
		if (stats1.errors_ss) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "ss", stats1.errors_ss, stats1.errortime_ss);
		else $display("Hint: Output '%s' has no mismatches.", "ss");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { pm_ref, hh_ref, mm_ref, ss_ref } === ( { pm_ref, hh_ref, mm_ref, ss_ref } ^ { pm_dut, hh_dut, mm_dut, ss_dut } ^ { pm_ref, hh_ref, mm_ref, ss_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (pm_ref !== ( pm_ref ^ pm_dut ^ pm_ref ))
		begin if (stats1.errors_pm == 0) stats1.errortime_pm = $time;
			stats1.errors_pm = stats1.errors_pm+1'b1; end
		if (hh_ref !== ( hh_ref ^ hh_dut ^ hh_ref ))
		begin if (stats1.errors_hh == 0) stats1.errortime_hh = $time;
			stats1.errors_hh = stats1.errors_hh+1'b1; end
		if (mm_ref !== ( mm_ref ^ mm_dut ^ mm_ref ))
		begin if (stats1.errors_mm == 0) stats1.errortime_mm = $time;
			stats1.errors_mm = stats1.errors_mm+1'b1; end
		if (ss_ref !== ( ss_ref ^ ss_dut ^ ss_ref ))
		begin if (stats1.errors_ss == 0) stats1.errortime_ss = $time;
			stats1.errors_ss = stats1.errors_ss+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

