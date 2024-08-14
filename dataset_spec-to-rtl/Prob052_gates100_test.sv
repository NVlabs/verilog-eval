`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	input tb_match,
	output logic [99:0] in,
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
		reg [3:0] count; count = 0;
		in <= 100'h0;
		// AND gate uses huge numbers and creates a sparse waveform.
		@(negedge clk) wavedrom_start("Test AND gate");
			@(posedge clk,negedge clk) in <= 100'h0;		// Test OR gate
			@(posedge clk,negedge clk); in <= ~100'h0;		// Test AND gate
			@(posedge clk,negedge clk); in <= 100'h3ffff;	
			@(posedge clk,negedge clk); in <= ~100'h3ffff;	
			@(posedge clk,negedge clk); in <= 100'h80;		
			@(posedge clk,negedge clk); in <= ~100'h80;		
		wavedrom_stop();

		@(negedge clk) wavedrom_start("Test OR and XOR gates");
			@(posedge clk) in <= 100'h0;		// Test OR gate
			@(posedge clk); in <= 100'h7;		// Test AND gate
			repeat(10) @(posedge clk, negedge clk) begin
				in <= count;		
				count <= count + 1;
			end
			@(posedge clk) in <= 100'h0;
		@(negedge clk) wavedrom_stop();
		
		in <= $random;
		repeat(100) begin
			@(negedge clk) in <= $random;
			@(posedge clk) in <= $random;
		end
		for (int i=0;i<100;i++) begin
			@(negedge clk) in <= 100'h1<<i;
			@(posedge clk) in <= ~(100'h1<<i);
		end
		@(posedge clk) in <= 100'h0;		// Test OR gate
		@(posedge clk); in <= ~100'h0;		// Test AND gate
		@(posedge clk);
		#1 $finish;
	end
		
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_and;
		int errortime_out_and;
		int errors_out_or;
		int errortime_out_or;
		int errors_out_xor;
		int errortime_out_xor;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [99:0] in;
	logic out_and_ref;
	logic out_and_dut;
	logic out_or_ref;
	logic out_or_dut;
	logic out_xor_ref;
	logic out_xor_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,in,out_and_ref,out_and_dut,out_or_ref,out_or_dut,out_xor_ref,out_xor_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.in );
	RefModule good1 (
		.in,
		.out_and(out_and_ref),
		.out_or(out_or_ref),
		.out_xor(out_xor_ref) );
		
	TopModule top_module1 (
		.in,
		.out_and(out_and_dut),
		.out_or(out_or_dut),
		.out_xor(out_xor_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_and) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_and", stats1.errors_out_and, stats1.errortime_out_and);
		else $display("Hint: Output '%s' has no mismatches.", "out_and");
		if (stats1.errors_out_or) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_or", stats1.errors_out_or, stats1.errortime_out_or);
		else $display("Hint: Output '%s' has no mismatches.", "out_or");
		if (stats1.errors_out_xor) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_xor", stats1.errors_out_xor, stats1.errortime_out_xor);
		else $display("Hint: Output '%s' has no mismatches.", "out_xor");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_and_ref, out_or_ref, out_xor_ref } === ( { out_and_ref, out_or_ref, out_xor_ref } ^ { out_and_dut, out_or_dut, out_xor_dut } ^ { out_and_ref, out_or_ref, out_xor_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_and_ref !== ( out_and_ref ^ out_and_dut ^ out_and_ref ))
		begin if (stats1.errors_out_and == 0) stats1.errortime_out_and = $time;
			stats1.errors_out_and = stats1.errors_out_and+1'b1; end
		if (out_or_ref !== ( out_or_ref ^ out_or_dut ^ out_or_ref ))
		begin if (stats1.errors_out_or == 0) stats1.errortime_out_or = $time;
			stats1.errors_out_or = stats1.errors_out_or+1'b1; end
		if (out_xor_ref !== ( out_xor_ref ^ out_xor_dut ^ out_xor_ref ))
		begin if (stats1.errors_out_xor == 0) stats1.errortime_out_xor = $time;
			stats1.errors_out_xor = stats1.errors_out_xor+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

