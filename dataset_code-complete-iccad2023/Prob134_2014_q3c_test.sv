`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic x,
	output logic [2:0] y
);

	initial begin
		repeat(200) @(posedge clk, negedge clk) begin
			y <= $random;
			x <= $random;
		end
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_Y0;
		int errortime_Y0;
		int errors_z;
		int errortime_z;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic x;
	logic [2:0] y;
	logic Y0_ref;
	logic Y0_dut;
	logic z_ref;
	logic z_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,x,y,Y0_ref,Y0_dut,z_ref,z_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.x,
		.y );
	RefModule good1 (
		.x,
		.y,
		.Y0(Y0_ref),
		.z(z_ref) );
		
	TopModule top_module1 (
		.x,
		.y,
		.Y0(Y0_dut),
		.z(z_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_Y0) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Y0", stats1.errors_Y0, stats1.errortime_Y0);
		else $display("Hint: Output '%s' has no mismatches.", "Y0");
		if (stats1.errors_z) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "z", stats1.errors_z, stats1.errortime_z);
		else $display("Hint: Output '%s' has no mismatches.", "z");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { Y0_ref, z_ref } === ( { Y0_ref, z_ref } ^ { Y0_dut, z_dut } ^ { Y0_ref, z_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (Y0_ref !== ( Y0_ref ^ Y0_dut ^ Y0_ref ))
		begin if (stats1.errors_Y0 == 0) stats1.errortime_Y0 = $time;
			stats1.errors_Y0 = stats1.errors_Y0+1'b1; end
		if (z_ref !== ( z_ref ^ z_dut ^ z_ref ))
		begin if (stats1.errors_z == 0) stats1.errortime_z = $time;
			stats1.errors_z = stats1.errors_z+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

