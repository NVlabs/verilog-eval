`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg reset, data,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable,
	input tb_match
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


	wire [0:9] d = 10'b1110110011;
	
	
	initial begin
		reset <= 1;
		@(posedge clk) reset <= 0;
		data <= 1;
		repeat(2) @(posedge clk) ;
		data <= 0;
		@(posedge clk);
		data <= 1;
		@(posedge clk);
		data <= 0;
	
		wavedrom_start("Reset and sequence detect");
		reset_test();
		for (int i=0;i<10;i++) begin
			@(posedge clk) data <= d[i];
		end
		wavedrom_stop();
		repeat(600) @(posedge clk, negedge clk) begin
			reset <= !($random & 31);
			data <= $random;
		end

		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_start_shifting;
		int errortime_start_shifting;

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
	logic data;
	logic start_shifting_ref;
	logic start_shifting_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,reset,data,start_shifting_ref,start_shifting_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.reset,
		.data );
	RefModule good1 (
		.clk,
		.reset,
		.data,
		.start_shifting(start_shifting_ref) );
		
	TopModule top_module1 (
		.clk,
		.reset,
		.data,
		.start_shifting(start_shifting_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_start_shifting) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "start_shifting", stats1.errors_start_shifting, stats1.errortime_start_shifting);
		else $display("Hint: Output '%s' has no mismatches.", "start_shifting");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { start_shifting_ref } === ( { start_shifting_ref } ^ { start_shifting_dut } ^ { start_shifting_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (start_shifting_ref !== ( start_shifting_ref ^ start_shifting_dut ^ start_shifting_ref ))
		begin if (stats1.errors_start_shifting == 0) stats1.errortime_start_shifting = $time;
			stats1.errors_start_shifting = stats1.errors_start_shifting+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

