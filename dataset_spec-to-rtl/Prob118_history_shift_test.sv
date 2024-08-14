`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13

module stimulus_gen
(
	input clk,
	output logic areset,
	
	output logic predict_valid,
	output predict_taken,
	
	output logic train_mispredicted,
	output train_taken,
	output [31:0] train_history,

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
	logic predict_taken_r;
	assign predict_taken = predict_valid ? predict_taken_r : 1'bx;
	
	logic train_taken_r;
	logic [31:0] train_history_r;
	assign train_taken = train_mispredicted ? train_taken_r : 1'bx;
	assign train_history = train_mispredicted ? train_history_r : 32'hx;
	
	
	initial begin
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		predict_taken_r <= 1;
		predict_valid <= 1;
		train_mispredicted <= 0;
		train_history_r <= 32'h5;
		train_taken_r <= 1;
	
		wavedrom_start("Asynchronous reset");
			reset_test(1); // Test for asynchronous reset
		wavedrom_stop();
		@(posedge clk) reset <= 1;
		predict_valid <= 0;

		wavedrom_start("Predictions: Shift in");
		repeat(2) @(posedge clk) {predict_valid, predict_taken_r} <= {$urandom};
		reset <= 0;
		predict_valid <= 1;
		repeat(6) @(posedge clk) {predict_taken_r} <= {$urandom};
		predict_valid <= 0;
		repeat(3) @(posedge clk) {predict_taken_r} <= {$urandom};
		predict_valid <= 1;
		train_mispredicted <= 1;
		@(posedge clk) train_mispredicted <= 0;
		repeat(6) @(posedge clk) {predict_taken_r} <= {$urandom};
		wavedrom_stop();

		repeat(2000) @(posedge clk,negedge clk) begin
			{predict_valid, predict_taken_r, train_taken_r} <= {$urandom};
			train_history_r <= $urandom;
			train_mispredicted <= !($urandom_range(0,31));
		end

		#1 $finish;
	end
	
	
endmodule
module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_predict_history;
		int errortime_predict_history;

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
	logic predict_valid;
	logic predict_taken;
	logic train_mispredicted;
	logic train_taken;
	logic [31:0] train_history;
	logic [31:0] predict_history_ref;
	logic [31:0] predict_history_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,areset,predict_valid,predict_taken,train_mispredicted,train_taken,train_history,predict_history_ref,predict_history_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.areset,
		.predict_valid,
		.predict_taken,
		.train_mispredicted,
		.train_taken,
		.train_history );
	RefModule good1 (
		.clk,
		.areset,
		.predict_valid,
		.predict_taken,
		.train_mispredicted,
		.train_taken,
		.train_history,
		.predict_history(predict_history_ref) );
		
	TopModule top_module1 (
		.clk,
		.areset,
		.predict_valid,
		.predict_taken,
		.train_mispredicted,
		.train_taken,
		.train_history,
		.predict_history(predict_history_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_predict_history) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "predict_history", stats1.errors_predict_history, stats1.errortime_predict_history);
		else $display("Hint: Output '%s' has no mismatches.", "predict_history");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { predict_history_ref } === ( { predict_history_ref } ^ { predict_history_dut } ^ { predict_history_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (predict_history_ref !== ( predict_history_ref ^ predict_history_dut ^ predict_history_ref ))
		begin if (stats1.errors_predict_history == 0) stats1.errortime_predict_history = $time;
			stats1.errors_predict_history = stats1.errors_predict_history+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

