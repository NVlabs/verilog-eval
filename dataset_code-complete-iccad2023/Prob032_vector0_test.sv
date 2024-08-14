`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg [2:0] vec,
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
		vec <= 3'b0;
		@(negedge clk);
		wavedrom_start();
		repeat(10) @(posedge clk)
			vec <= count++;		
		wavedrom_stop();
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_outv;
		int errortime_outv;
		int errors_o2;
		int errortime_o2;
		int errors_o1;
		int errortime_o1;
		int errors_o0;
		int errortime_o0;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [2:0] vec;
	logic [2:0] outv_ref;
	logic [2:0] outv_dut;
	logic o2_ref;
	logic o2_dut;
	logic o1_ref;
	logic o1_dut;
	logic o0_ref;
	logic o0_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,vec,outv_ref,outv_dut,o2_ref,o2_dut,o1_ref,o1_dut,o0_ref,o0_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.vec );
	RefModule good1 (
		.vec,
		.outv(outv_ref),
		.o2(o2_ref),
		.o1(o1_ref),
		.o0(o0_ref) );
		
	TopModule top_module1 (
		.vec,
		.outv(outv_dut),
		.o2(o2_dut),
		.o1(o1_dut),
		.o0(o0_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_outv) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "outv", stats1.errors_outv, stats1.errortime_outv);
		else $display("Hint: Output '%s' has no mismatches.", "outv");
		if (stats1.errors_o2) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "o2", stats1.errors_o2, stats1.errortime_o2);
		else $display("Hint: Output '%s' has no mismatches.", "o2");
		if (stats1.errors_o1) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "o1", stats1.errors_o1, stats1.errortime_o1);
		else $display("Hint: Output '%s' has no mismatches.", "o1");
		if (stats1.errors_o0) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "o0", stats1.errors_o0, stats1.errortime_o0);
		else $display("Hint: Output '%s' has no mismatches.", "o0");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { outv_ref, o2_ref, o1_ref, o0_ref } === ( { outv_ref, o2_ref, o1_ref, o0_ref } ^ { outv_dut, o2_dut, o1_dut, o0_dut } ^ { outv_ref, o2_ref, o1_ref, o0_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (outv_ref !== ( outv_ref ^ outv_dut ^ outv_ref ))
		begin if (stats1.errors_outv == 0) stats1.errortime_outv = $time;
			stats1.errors_outv = stats1.errors_outv+1'b1; end
		if (o2_ref !== ( o2_ref ^ o2_dut ^ o2_ref ))
		begin if (stats1.errors_o2 == 0) stats1.errortime_o2 = $time;
			stats1.errors_o2 = stats1.errors_o2+1'b1; end
		if (o1_ref !== ( o1_ref ^ o1_dut ^ o1_ref ))
		begin if (stats1.errors_o1 == 0) stats1.errortime_o1 = $time;
			stats1.errors_o1 = stats1.errors_o1+1'b1; end
		if (o0_ref !== ( o0_ref ^ o0_dut ^ o0_ref ))
		begin if (stats1.errors_o0 == 0) stats1.errortime_o0 = $time;
			stats1.errors_o0 = stats1.errors_o0+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

