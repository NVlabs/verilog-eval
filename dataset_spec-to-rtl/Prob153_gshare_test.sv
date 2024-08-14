`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen
#(parameter N=7)
(
	input clk,
	output logic areset,
	
	output logic predict_valid,
	output [N-1:0] predict_pc,
	
	output logic train_valid,
	output train_taken,
	output train_mispredicted,
	output [N-1:0] train_history,
	output [N-1:0] train_pc,

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
	
	logic [N-1:0] predict_pc_r;
	logic train_taken_r;
	logic train_mispredicted_r;
	logic [N-1:0] train_history_r;
	logic [N-1:0] train_pc_r;
	
	assign predict_pc = predict_valid ? predict_pc_r : {N{1'bx}};
	assign train_taken = train_valid ? train_taken_r : 1'bx;
	assign train_mispredicted = train_valid ? train_mispredicted_r : 1'bx;
	assign train_history = train_valid ? train_history_r : {N{1'bx}};
	assign train_pc = train_valid ? train_pc_r : {N{1'bx}};
	
	
	initial begin
		@(posedge clk) reset <= 1;
		@(posedge clk) reset <= 0;
		predict_valid <= 1;
		train_mispredicted_r <= 1;
		train_history_r <= 7'h7f;
		train_pc_r <= 7'h4;
		train_taken_r <= 1;
		train_valid <= 1;
		predict_valid <= 1;
		predict_pc_r <= 4;
	
		wavedrom_start("Asynchronous reset");
			reset_test(1); // Test for asynchronous reset
		wavedrom_stop();
		@(posedge clk) reset <= 1;
		predict_valid <= 0;

		wavedrom_start("Training entries (pc = 0xa, history = 0 and 2)");
		predict_pc_r <= 7'ha;
		predict_valid <= 1;

		train_history_r <= 7'h0;
		train_pc_r <= 7'ha;
		train_taken_r <= 1;
		train_valid <= 0;
		train_mispredicted_r <= 0;
		
		@(negedge clk) reset <= 0;
		@(posedge clk) train_valid <= 1;
		@(posedge clk) train_history_r <= 7'h2;
		@(posedge clk) train_valid <= 0;

		repeat(4) @(posedge clk);
		train_history_r <= 7'h0;
		train_taken_r <= 0;
		train_valid <= 1;
		@(posedge clk) train_valid <= 0;
		
		repeat(8) @(posedge clk);
		wavedrom_stop();

		@(posedge clk);

		wavedrom_start("History register recovery on misprediction");
		reset <= 1;
		predict_pc_r <= 7'ha;
		predict_valid <= 1;

		train_history_r <= 7'h0;
		train_pc_r <= 7'ha;
		train_taken_r <= 1;
		train_valid <= 0;
		train_mispredicted_r <= 1;
		
		@(negedge clk) reset <= 0;
		@(posedge clk);
		@(posedge clk) train_valid <= 1;
		@(posedge clk) train_valid <= 0;
		@(posedge clk) train_valid <= 1;
		train_history_r <= 7'h10;
		train_taken_r <= 0;
		@(posedge clk) train_valid <= 0;

		repeat(4) @(posedge clk);
		train_history_r <= 7'h0;
		train_taken_r <= 0;
		train_valid <= 1;
		@(posedge clk) train_valid <= 0;
		@(posedge clk) train_valid <= 1;
		train_history_r <= 7'h20;
		@(posedge clk) train_valid <= 0;
		
		repeat(3) @(posedge clk);
		wavedrom_stop();

		repeat(1000) @(posedge clk,negedge clk) begin
			{predict_valid, predict_pc_r, train_pc_r, train_taken_r, train_valid} <= {$urandom};
			train_history_r <= $urandom;
			train_mispredicted_r <= !($urandom_range(0,31));
		end

		#1 $finish;
	end
	
	
endmodule
module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_predict_taken;
		int errortime_predict_taken;
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
	logic [6:0] predict_pc;
	logic train_valid;
	logic train_taken;
	logic train_mispredicted;
	logic [6:0] train_history;
	logic [6:0] train_pc;
	logic predict_taken_ref;
	logic predict_taken_dut;
	logic [6:0] predict_history_ref;
	logic [6:0] predict_history_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,areset,predict_valid,predict_pc,train_valid,train_taken,train_mispredicted,train_history,train_pc,predict_taken_ref,predict_taken_dut,predict_history_ref,predict_history_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.areset,
		.predict_valid,
		.predict_pc,
		.train_valid,
		.train_taken,
		.train_mispredicted,
		.train_history,
		.train_pc );
	RefModule good1 (
		.clk,
		.areset,
		.predict_valid,
		.predict_pc,
		.train_valid,
		.train_taken,
		.train_mispredicted,
		.train_history,
		.train_pc,
		.predict_taken(predict_taken_ref),
		.predict_history(predict_history_ref) );
		
	TopModule top_module1 (
		.clk,
		.areset,
		.predict_valid,
		.predict_pc,
		.train_valid,
		.train_taken,
		.train_mispredicted,
		.train_history,
		.train_pc,
		.predict_taken(predict_taken_dut),
		.predict_history(predict_history_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_predict_taken) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "predict_taken", stats1.errors_predict_taken, stats1.errortime_predict_taken);
		else $display("Hint: Output '%s' has no mismatches.", "predict_taken");
		if (stats1.errors_predict_history) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "predict_history", stats1.errors_predict_history, stats1.errortime_predict_history);
		else $display("Hint: Output '%s' has no mismatches.", "predict_history");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { predict_taken_ref, predict_history_ref } === ( { predict_taken_ref, predict_history_ref } ^ { predict_taken_dut, predict_history_dut } ^ { predict_taken_ref, predict_history_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (predict_taken_ref !== ( predict_taken_ref ^ predict_taken_dut ^ predict_taken_ref ))
		begin if (stats1.errors_predict_taken == 0) stats1.errortime_predict_taken = $time;
			stats1.errors_predict_taken = stats1.errors_predict_taken+1'b1; end
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

