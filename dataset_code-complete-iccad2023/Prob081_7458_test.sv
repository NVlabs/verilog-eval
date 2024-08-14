`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg p1a, p1b, p1c, p1d, p1e, p1f,
	output reg p2a, p2b, p2c, p2d,
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
		{p1a,p1b,p1c,p1d,p1e,p1f} <= 4'h0;		
		{p2a,p2b,p2c,p2d} <= 4'h0;		
		wavedrom_start();
		repeat(20) @(posedge clk) begin
			{p1a,p1b,p1c,p1d,p1e,p1f} <= {count[2:0], count[3:1]};		
			{p2a,p2b,p2c,p2d} <= count;		
			count = count + 1;
		end
		wavedrom_stop();

		repeat(400) @(posedge clk,negedge clk) begin
			{p1a,p1b,p1c,p1d,p2a,p2b,p2c,p2d} <= $random;		
		end
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_p1y;
		int errortime_p1y;
		int errors_p2y;
		int errortime_p2y;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic p1a;
	logic p1b;
	logic p1c;
	logic p1d;
	logic p1e;
	logic p1f;
	logic p2a;
	logic p2b;
	logic p2c;
	logic p2d;
	logic p1y_ref;
	logic p1y_dut;
	logic p2y_ref;
	logic p2y_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,p1a,p1b,p1c,p1d,p1e,p1f,p2a,p2b,p2c,p2d,p1y_ref,p1y_dut,p2y_ref,p2y_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.p1a,
		.p1b,
		.p1c,
		.p1d,
		.p1e,
		.p1f,
		.p2a,
		.p2b,
		.p2c,
		.p2d );
	RefModule good1 (
		.p1a,
		.p1b,
		.p1c,
		.p1d,
		.p1e,
		.p1f,
		.p2a,
		.p2b,
		.p2c,
		.p2d,
		.p1y(p1y_ref),
		.p2y(p2y_ref) );
		
	TopModule top_module1 (
		.p1a,
		.p1b,
		.p1c,
		.p1d,
		.p1e,
		.p1f,
		.p2a,
		.p2b,
		.p2c,
		.p2d,
		.p1y(p1y_dut),
		.p2y(p2y_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_p1y) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "p1y", stats1.errors_p1y, stats1.errortime_p1y);
		else $display("Hint: Output '%s' has no mismatches.", "p1y");
		if (stats1.errors_p2y) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "p2y", stats1.errors_p2y, stats1.errortime_p2y);
		else $display("Hint: Output '%s' has no mismatches.", "p2y");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { p1y_ref, p2y_ref } === ( { p1y_ref, p2y_ref } ^ { p1y_dut, p2y_dut } ^ { p1y_ref, p2y_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (p1y_ref !== ( p1y_ref ^ p1y_dut ^ p1y_ref ))
		begin if (stats1.errors_p1y == 0) stats1.errortime_p1y = $time;
			stats1.errors_p1y = stats1.errors_p1y+1'b1; end
		if (p2y_ref !== ( p2y_ref ^ p2y_dut ^ p2y_ref ))
		begin if (stats1.errors_p2y == 0) stats1.errortime_p2y = $time;
			stats1.errors_p2y = stats1.errors_p2y+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

