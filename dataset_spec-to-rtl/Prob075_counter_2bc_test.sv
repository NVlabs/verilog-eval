`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen(
	input clk,
	output logic areset,
	output logic train_valid,
	output train_taken,

	input tb_match,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable,
	output int wavedrom_hide_after_time	
);


// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	


	reg reset;
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

	
	assign areset = reset;
	logic train_taken_r;
	assign train_taken = train_valid ? train_taken_r : 1'bx;
	
	initial begin
		@(posedge clk);
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		train_taken_r <= 1;
		train_valid <= 1;
	
		wavedrom_start("Asynchronous reset");
			reset_test(1); // Test for asynchronous reset
		wavedrom_stop();
		@(posedge clk) reset <= 1;
		train_taken_r <= 1;
		train_valid <= 0;
		@(posedge clk) reset <= 0;

		wavedrom_start("Count up, then down");
		train_taken_r <= 1;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 0;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 0;
			@(posedge clk) train_valid <= 1;
		train_taken_r <= 0;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 0;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 1;
			@(posedge clk) train_valid <= 0;
			@(posedge clk) train_valid <= 1;		
		wavedrom_stop();

		repeat(1000) @(posedge clk,negedge clk) 
			{train_valid, train_taken_r} <= {$urandom} ;

		#1 $finish;
	end
	
	
endmodule
module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_state;
		int errortime_state;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic areset;
	logic train_valid;
	logic train_taken;
	logic [1:0] state_ref;
	logic [1:0] state_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,areset,train_valid,train_taken,state_ref,state_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.areset,
		.train_valid,
		.train_taken );
	RefModule good1 (
		.clk,
		.areset,
		.train_valid,
		.train_taken,
		.state(state_ref) );
		
	TopModule top_module1 (
		.clk,
		.areset,
		.train_valid,
		.train_taken,
		.state(state_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_state) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "state", stats1.errors_state, stats1.errortime_state);
		else $display("Hint: Output '%s' has no mismatches.", "state");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { state_ref } === ( { state_ref } ^ { state_dut } ^ { state_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (state_ref !== ( state_ref ^ state_dut ^ state_ref ))
		begin if (stats1.errors_state == 0) stats1.errortime_state = $time;
			stats1.errors_state = stats1.errors_state+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

