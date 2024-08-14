`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg ring, vibrate_mode,
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
		{vibrate_mode,ring} <= 1'b0;
		wavedrom_start();
		repeat(10) @(posedge clk)
			{vibrate_mode,ring} <= count++;		
		wavedrom_stop();
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_ringer;
		int errortime_ringer;
		int errors_motor;
		int errortime_motor;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic ring;
	logic vibrate_mode;
	logic ringer_ref;
	logic ringer_dut;
	logic motor_ref;
	logic motor_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,ring,vibrate_mode,ringer_ref,ringer_dut,motor_ref,motor_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.ring,
		.vibrate_mode );
	RefModule good1 (
		.ring,
		.vibrate_mode,
		.ringer(ringer_ref),
		.motor(motor_ref) );
		
	TopModule top_module1 (
		.ring,
		.vibrate_mode,
		.ringer(ringer_dut),
		.motor(motor_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_ringer) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "ringer", stats1.errors_ringer, stats1.errortime_ringer);
		else $display("Hint: Output '%s' has no mismatches.", "ringer");
		if (stats1.errors_motor) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "motor", stats1.errors_motor, stats1.errortime_motor);
		else $display("Hint: Output '%s' has no mismatches.", "motor");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { ringer_ref, motor_ref } === ( { ringer_ref, motor_ref } ^ { ringer_dut, motor_dut } ^ { ringer_ref, motor_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (ringer_ref !== ( ringer_ref ^ ringer_dut ^ ringer_ref ))
		begin if (stats1.errors_ringer == 0) stats1.errortime_ringer = $time;
			stats1.errors_ringer = stats1.errors_ringer+1'b1; end
		if (motor_ref !== ( motor_ref ^ motor_dut ^ motor_ref ))
		begin if (stats1.errors_motor == 0) stats1.errortime_motor = $time;
			stats1.errors_motor = stats1.errors_motor+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

