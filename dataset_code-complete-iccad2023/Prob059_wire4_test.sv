`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic a, b, c,
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



	always @(posedge clk, negedge clk)
		{a,b,c} <= $random;
	
	initial begin
		@(negedge clk) wavedrom_start();
			repeat(8) @(posedge clk);
		@(negedge clk) wavedrom_stop();
		repeat(100) @(negedge clk);
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_w;
		int errortime_w;
		int errors_x;
		int errortime_x;
		int errors_y;
		int errortime_y;
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

	logic a;
	logic b;
	logic c;
	logic w_ref;
	logic w_dut;
	logic x_ref;
	logic x_dut;
	logic y_ref;
	logic y_dut;
	logic z_ref;
	logic z_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,c,w_ref,w_dut,x_ref,x_dut,y_ref,y_dut,z_ref,z_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b,
		.c );
	RefModule good1 (
		.a,
		.b,
		.c,
		.w(w_ref),
		.x(x_ref),
		.y(y_ref),
		.z(z_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.c,
		.w(w_dut),
		.x(x_dut),
		.y(y_dut),
		.z(z_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_w) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "w", stats1.errors_w, stats1.errortime_w);
		else $display("Hint: Output '%s' has no mismatches.", "w");
		if (stats1.errors_x) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "x", stats1.errors_x, stats1.errortime_x);
		else $display("Hint: Output '%s' has no mismatches.", "x");
		if (stats1.errors_y) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "y", stats1.errors_y, stats1.errortime_y);
		else $display("Hint: Output '%s' has no mismatches.", "y");
		if (stats1.errors_z) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "z", stats1.errors_z, stats1.errortime_z);
		else $display("Hint: Output '%s' has no mismatches.", "z");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { w_ref, x_ref, y_ref, z_ref } === ( { w_ref, x_ref, y_ref, z_ref } ^ { w_dut, x_dut, y_dut, z_dut } ^ { w_ref, x_ref, y_ref, z_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (w_ref !== ( w_ref ^ w_dut ^ w_ref ))
		begin if (stats1.errors_w == 0) stats1.errortime_w = $time;
			stats1.errors_w = stats1.errors_w+1'b1; end
		if (x_ref !== ( x_ref ^ x_dut ^ x_ref ))
		begin if (stats1.errors_x == 0) stats1.errortime_x = $time;
			stats1.errors_x = stats1.errors_x+1'b1; end
		if (y_ref !== ( y_ref ^ y_dut ^ y_ref ))
		begin if (stats1.errors_y == 0) stats1.errortime_y = $time;
			stats1.errors_y = stats1.errors_y+1'b1; end
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

