`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg [2:0] a, b,
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
		int count; count = 6'h38;
		{b, a} <= 6'b0;
		@(negedge clk);
		wavedrom_start();
		repeat(30) @(posedge clk)
			{b, a} <= count++;		
		wavedrom_stop();
		
		repeat(200) @(posedge clk, negedge clk)
			{b,a} <= $random;
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_or_bitwise;
		int errortime_out_or_bitwise;
		int errors_out_or_logical;
		int errortime_out_or_logical;
		int errors_out_not;
		int errortime_out_not;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [2:0] a;
	logic [2:0] b;
	logic [2:0] out_or_bitwise_ref;
	logic [2:0] out_or_bitwise_dut;
	logic out_or_logical_ref;
	logic out_or_logical_dut;
	logic [5:0] out_not_ref;
	logic [5:0] out_not_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,out_or_bitwise_ref,out_or_bitwise_dut,out_or_logical_ref,out_or_logical_dut,out_not_ref,out_not_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b );
	RefModule good1 (
		.a,
		.b,
		.out_or_bitwise(out_or_bitwise_ref),
		.out_or_logical(out_or_logical_ref),
		.out_not(out_not_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.out_or_bitwise(out_or_bitwise_dut),
		.out_or_logical(out_or_logical_dut),
		.out_not(out_not_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_or_bitwise) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_or_bitwise", stats1.errors_out_or_bitwise, stats1.errortime_out_or_bitwise);
		else $display("Hint: Output '%s' has no mismatches.", "out_or_bitwise");
		if (stats1.errors_out_or_logical) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_or_logical", stats1.errors_out_or_logical, stats1.errortime_out_or_logical);
		else $display("Hint: Output '%s' has no mismatches.", "out_or_logical");
		if (stats1.errors_out_not) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_not", stats1.errors_out_not, stats1.errortime_out_not);
		else $display("Hint: Output '%s' has no mismatches.", "out_not");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_or_bitwise_ref, out_or_logical_ref, out_not_ref } === ( { out_or_bitwise_ref, out_or_logical_ref, out_not_ref } ^ { out_or_bitwise_dut, out_or_logical_dut, out_not_dut } ^ { out_or_bitwise_ref, out_or_logical_ref, out_not_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_or_bitwise_ref !== ( out_or_bitwise_ref ^ out_or_bitwise_dut ^ out_or_bitwise_ref ))
		begin if (stats1.errors_out_or_bitwise == 0) stats1.errortime_out_or_bitwise = $time;
			stats1.errors_out_or_bitwise = stats1.errors_out_or_bitwise+1'b1; end
		if (out_or_logical_ref !== ( out_or_logical_ref ^ out_or_logical_dut ^ out_or_logical_ref ))
		begin if (stats1.errors_out_or_logical == 0) stats1.errortime_out_or_logical = $time;
			stats1.errors_out_or_logical = stats1.errors_out_or_logical+1'b1; end
		if (out_not_ref !== ( out_not_ref ^ out_not_dut ^ out_not_ref ))
		begin if (stats1.errors_out_not == 0) stats1.errortime_out_not = $time;
			stats1.errors_out_not = stats1.errors_out_not+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

