`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13



module stimulus_gen (
	input clk,
	output logic do_sub,
	output logic [7:0] a, b,
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


	
	initial begin
		{a, b} <= 16'haabb;
		do_sub <= 0;
		@(negedge clk) wavedrom_start("");
			@(posedge clk, negedge clk) do_sub <= 0;
			@(posedge clk, negedge clk) do_sub <= 0;
			@(posedge clk, negedge clk) do_sub <= 1;
			@(posedge clk, negedge clk) do_sub <= 1;
			
			@(posedge clk, negedge clk) {a, b} <= 16'h0303; do_sub <= 1'b0;
			@(posedge clk, negedge clk) do_sub <= 0;
			@(posedge clk, negedge clk) do_sub <= 1;
			@(posedge clk, negedge clk) {a, b} <= 16'h0304; do_sub <= 1'b0;
			@(posedge clk, negedge clk) do_sub <= 0;
			@(posedge clk, negedge clk) do_sub <= 1;
			@(posedge clk, negedge clk) {a, b} <= 16'hfd03; do_sub <= 1'b0;
			@(posedge clk, negedge clk) do_sub <= 0;
			@(posedge clk, negedge clk) do_sub <= 1;
			@(posedge clk, negedge clk) {a, b} <= 16'hfd04; do_sub <= 1'b0;
			@(posedge clk, negedge clk) do_sub <= 0;
			@(posedge clk, negedge clk) do_sub <= 1;
		wavedrom_stop();
		
		repeat(100) @(posedge clk, negedge clk) begin
			{a,b, do_sub} <= $urandom;
		end
			
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out;
		int errortime_out;
		int errors_result_is_zero;
		int errortime_result_is_zero;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic do_sub;
	logic [7:0] a;
	logic [7:0] b;
	logic [7:0] out_ref;
	logic [7:0] out_dut;
	logic result_is_zero_ref;
	logic result_is_zero_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,do_sub,a,b,out_ref,out_dut,result_is_zero_ref,result_is_zero_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.do_sub,
		.a,
		.b );
	RefModule good1 (
		.do_sub,
		.a,
		.b,
		.out(out_ref),
		.result_is_zero(result_is_zero_ref) );
		
	TopModule top_module1 (
		.do_sub,
		.a,
		.b,
		.out(out_dut),
		.result_is_zero(result_is_zero_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out", stats1.errors_out, stats1.errortime_out);
		else $display("Hint: Output '%s' has no mismatches.", "out");
		if (stats1.errors_result_is_zero) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "result_is_zero", stats1.errors_result_is_zero, stats1.errortime_result_is_zero);
		else $display("Hint: Output '%s' has no mismatches.", "result_is_zero");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_ref, result_is_zero_ref } === ( { out_ref, result_is_zero_ref } ^ { out_dut, result_is_zero_dut } ^ { out_ref, result_is_zero_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_ref !== ( out_ref ^ out_dut ^ out_ref ))
		begin if (stats1.errors_out == 0) stats1.errortime_out = $time;
			stats1.errors_out = stats1.errors_out+1'b1; end
		if (result_is_zero_ref !== ( result_is_zero_ref ^ result_is_zero_dut ^ result_is_zero_ref ))
		begin if (stats1.errors_result_is_zero == 0) stats1.errortime_result_is_zero = $time;
			stats1.errors_result_is_zero = stats1.errors_result_is_zero+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

