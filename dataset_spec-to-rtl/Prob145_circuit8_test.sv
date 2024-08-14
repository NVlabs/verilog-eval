`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic clock=0,
	output logic a,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable	
);

	always begin
		repeat(3) @(posedge clk);
		clock = ~clock;
	end


// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	



	initial begin
		a <= 0;
		@(negedge clock) {a} <= 0;
		@(negedge clk) wavedrom_start("Unknown circuit");
			@(posedge clk) {a} <= 0;
			repeat(14) @(posedge clk,negedge clk) a <= ~a;
			repeat(5) @(posedge clk, negedge clk);
			repeat(8) @(posedge clk,negedge clk) a <= ~a;
		wavedrom_stop();

		repeat(200) @(posedge clk, negedge clk)
			a <= $urandom;
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_p;
		int errortime_p;
		int errors_q;
		int errortime_q;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic clock;
	logic a;
	logic p_ref;
	logic p_dut;
	logic q_ref;
	logic q_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clock,a,p_ref,p_dut,q_ref,q_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.clock,
		.a );
	RefModule good1 (
		.clock,
		.a,
		.p(p_ref),
		.q(q_ref) );
		
	TopModule top_module1 (
		.clock,
		.a,
		.p(p_dut),
		.q(q_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_p) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "p", stats1.errors_p, stats1.errortime_p);
		else $display("Hint: Output '%s' has no mismatches.", "p");
		if (stats1.errors_q) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "q", stats1.errors_q, stats1.errortime_q);
		else $display("Hint: Output '%s' has no mismatches.", "q");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { p_ref, q_ref } === ( { p_ref, q_ref } ^ { p_dut, q_dut } ^ { p_ref, q_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (p_ref !== ( p_ref ^ p_dut ^ p_ref ))
		begin if (stats1.errors_p == 0) stats1.errortime_p = $time;
			stats1.errors_p = stats1.errors_p+1'b1; end
		if (q_ref !== ( q_ref ^ q_dut ^ q_ref ))
		begin if (stats1.errors_q == 0) stats1.errortime_q = $time;
			stats1.errors_q = stats1.errors_q+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

