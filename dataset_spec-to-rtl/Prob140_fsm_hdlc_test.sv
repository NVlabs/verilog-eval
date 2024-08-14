`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic reset, in
);

	
	initial begin
		reset <= 1;
		in <= 0;
		@(posedge clk);
		repeat(800) @(posedge clk, negedge clk) begin
			reset <= !($random & 31);
			in <= |($random&7);
		end
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_disc;
		int errortime_disc;
		int errors_flag;
		int errortime_flag;
		int errors_err;
		int errortime_err;

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
	logic in;
	logic disc_ref;
	logic disc_dut;
	logic flag_ref;
	logic flag_dut;
	logic err_ref;
	logic err_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,reset,in,disc_ref,disc_dut,flag_ref,flag_dut,err_ref,err_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.reset,
		.in );
	RefModule good1 (
		.clk,
		.reset,
		.in,
		.disc(disc_ref),
		.flag(flag_ref),
		.err(err_ref) );
		
	TopModule top_module1 (
		.clk,
		.reset,
		.in,
		.disc(disc_dut),
		.flag(flag_dut),
		.err(err_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_disc) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "disc", stats1.errors_disc, stats1.errortime_disc);
		else $display("Hint: Output '%s' has no mismatches.", "disc");
		if (stats1.errors_flag) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "flag", stats1.errors_flag, stats1.errortime_flag);
		else $display("Hint: Output '%s' has no mismatches.", "flag");
		if (stats1.errors_err) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "err", stats1.errors_err, stats1.errortime_err);
		else $display("Hint: Output '%s' has no mismatches.", "err");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { disc_ref, flag_ref, err_ref } === ( { disc_ref, flag_ref, err_ref } ^ { disc_dut, flag_dut, err_dut } ^ { disc_ref, flag_ref, err_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (disc_ref !== ( disc_ref ^ disc_dut ^ disc_ref ))
		begin if (stats1.errors_disc == 0) stats1.errortime_disc = $time;
			stats1.errors_disc = stats1.errors_disc+1'b1; end
		if (flag_ref !== ( flag_ref ^ flag_dut ^ flag_ref ))
		begin if (stats1.errors_flag == 0) stats1.errortime_flag = $time;
			stats1.errors_flag = stats1.errors_flag+1'b1; end
		if (err_ref !== ( err_ref ^ err_dut ^ err_ref ))
		begin if (stats1.errors_err == 0) stats1.errortime_err = $time;
			stats1.errors_err = stats1.errors_err+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

