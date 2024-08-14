`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic reset,
	output logic [3:1] s,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable,
	input tb_match
);

// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	


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


	wire [3:0][2:0] val = { 3'h7, 3'h3, 3'h1, 3'h0 };
	integer sval;
	initial begin
		reset <= 1;
		s <= 1;
		reset_test();
		
		
		@(posedge clk) s <= 0;
		@(posedge clk) s <= 0;
		@(negedge clk) wavedrom_start("Water rises to highest level, then down to lowest level.");
			@(posedge clk) s <= 0;
			@(posedge clk) s <= 1;
			@(posedge clk) s <= 3;
			@(posedge clk) s <= 7;
			@(posedge clk) s <= 7;
			@(posedge clk) s <= 3;
			@(posedge clk) s <= 3;
			@(posedge clk) s <= 1;
			@(posedge clk) s <= 1;
			@(posedge clk) s <= 0;
			@(posedge clk) s <= 0;
		@(negedge clk) wavedrom_stop();
		
		sval = 0;
		repeat(1000) begin
			@(posedge clk);
				sval = sval + (sval == 3 ? 0 : $random&1);
				s <= val[sval];
			@(negedge clk);
				sval = sval - (sval == 0 ? 0 : $random&1);
				s <= val[sval];
		end

		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_fr3;
		int errortime_fr3;
		int errors_fr2;
		int errortime_fr2;
		int errors_fr1;
		int errortime_fr1;
		int errors_dfr;
		int errortime_dfr;

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
	logic [3:1] s;
	logic fr3_ref;
	logic fr3_dut;
	logic fr2_ref;
	logic fr2_dut;
	logic fr1_ref;
	logic fr1_dut;
	logic dfr_ref;
	logic dfr_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,reset,s,fr3_ref,fr3_dut,fr2_ref,fr2_dut,fr1_ref,fr1_dut,dfr_ref,dfr_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.reset,
		.s );
	RefModule good1 (
		.clk,
		.reset,
		.s,
		.fr3(fr3_ref),
		.fr2(fr2_ref),
		.fr1(fr1_ref),
		.dfr(dfr_ref) );
		
	TopModule top_module1 (
		.clk,
		.reset,
		.s,
		.fr3(fr3_dut),
		.fr2(fr2_dut),
		.fr1(fr1_dut),
		.dfr(dfr_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_fr3) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "fr3", stats1.errors_fr3, stats1.errortime_fr3);
		else $display("Hint: Output '%s' has no mismatches.", "fr3");
		if (stats1.errors_fr2) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "fr2", stats1.errors_fr2, stats1.errortime_fr2);
		else $display("Hint: Output '%s' has no mismatches.", "fr2");
		if (stats1.errors_fr1) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "fr1", stats1.errors_fr1, stats1.errortime_fr1);
		else $display("Hint: Output '%s' has no mismatches.", "fr1");
		if (stats1.errors_dfr) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "dfr", stats1.errors_dfr, stats1.errortime_dfr);
		else $display("Hint: Output '%s' has no mismatches.", "dfr");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { fr3_ref, fr2_ref, fr1_ref, dfr_ref } === ( { fr3_ref, fr2_ref, fr1_ref, dfr_ref } ^ { fr3_dut, fr2_dut, fr1_dut, dfr_dut } ^ { fr3_ref, fr2_ref, fr1_ref, dfr_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (fr3_ref !== ( fr3_ref ^ fr3_dut ^ fr3_ref ))
		begin if (stats1.errors_fr3 == 0) stats1.errortime_fr3 = $time;
			stats1.errors_fr3 = stats1.errors_fr3+1'b1; end
		if (fr2_ref !== ( fr2_ref ^ fr2_dut ^ fr2_ref ))
		begin if (stats1.errors_fr2 == 0) stats1.errortime_fr2 = $time;
			stats1.errors_fr2 = stats1.errors_fr2+1'b1; end
		if (fr1_ref !== ( fr1_ref ^ fr1_dut ^ fr1_ref ))
		begin if (stats1.errors_fr1 == 0) stats1.errortime_fr1 = $time;
			stats1.errors_fr1 = stats1.errors_fr1+1'b1; end
		if (dfr_ref !== ( dfr_ref ^ dfr_dut ^ dfr_ref ))
		begin if (stats1.errors_dfr == 0) stats1.errortime_dfr = $time;
			stats1.errors_dfr = stats1.errors_dfr+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

