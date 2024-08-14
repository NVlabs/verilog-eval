`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg a, b,
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
		int count; count = 0;
		{a,b} <= 1'b0;
		wavedrom_start("AND gate");
		repeat(10) @(posedge clk)
			{a,b} <= count++;		
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
		int errors_out_assign;
		int errortime_out_assign;
		int errors_out_alwaysblock;
		int errortime_out_alwaysblock;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic a;
	logic b;
	logic out_assign_ref;
	logic out_assign_dut;
	logic out_alwaysblock_ref;
	logic out_alwaysblock_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,out_assign_ref,out_assign_dut,out_alwaysblock_ref,out_alwaysblock_dut );
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
		.out_assign(out_assign_ref),
		.out_alwaysblock(out_alwaysblock_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.out_assign(out_assign_dut),
		.out_alwaysblock(out_alwaysblock_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_assign) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_assign", stats1.errors_out_assign, stats1.errortime_out_assign);
		else $display("Hint: Output '%s' has no mismatches.", "out_assign");
		if (stats1.errors_out_alwaysblock) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_alwaysblock", stats1.errors_out_alwaysblock, stats1.errortime_out_alwaysblock);
		else $display("Hint: Output '%s' has no mismatches.", "out_alwaysblock");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_assign_ref, out_alwaysblock_ref } === ( { out_assign_ref, out_alwaysblock_ref } ^ { out_assign_dut, out_alwaysblock_dut } ^ { out_assign_ref, out_alwaysblock_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_assign_ref !== ( out_assign_ref ^ out_assign_dut ^ out_assign_ref ))
		begin if (stats1.errors_out_assign == 0) stats1.errortime_out_assign = $time;
			stats1.errors_out_assign = stats1.errors_out_assign+1'b1; end
		if (out_alwaysblock_ref !== ( out_alwaysblock_ref ^ out_alwaysblock_dut ^ out_alwaysblock_ref ))
		begin if (stats1.errors_out_alwaysblock == 0) stats1.errortime_out_alwaysblock = $time;
			stats1.errors_out_alwaysblock = stats1.errors_out_alwaysblock+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

