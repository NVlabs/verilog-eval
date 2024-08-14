`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic S, enable,
	output logic A, B, C,
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
		enable <= 0;
		{A,B,C} <= 0;
		S <= 1'bx;
		@(negedge clk) wavedrom_start("A 3-input AND gate");
			@(posedge clk);
			@(posedge clk) enable <= 1; S <= 1;
			@(posedge clk) S <= 0;
			@(posedge clk) S <= 0;
			@(posedge clk) S <= 0;
			@(posedge clk) S <= 0;
			@(posedge clk) S <= 0;
			@(posedge clk) S <= 0;
			@(posedge clk) S <= 0;
			@(posedge clk) enable <= 0; S <= 1'bx;
			{A,B,C} <= 5;
			@(posedge clk) {A,B,C} <= 6;
			@(posedge clk) {A,B,C} <= 7;
			@(posedge clk) {A,B,C} <= 0;
			@(posedge clk) {A,B,C} <= 1;
		@(negedge clk) wavedrom_stop();

		repeat(500) @(posedge clk, negedge clk) begin
			{A,B,C,S} <= $random;
			enable <= ($random&3) == 0;
		end
		
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_Z;
		int errortime_Z;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic enable;
	logic S;
	logic A;
	logic B;
	logic C;
	logic Z_ref;
	logic Z_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,clk,enable,S,A,B,C,Z_ref,Z_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.enable,
		.S,
		.A,
		.B,
		.C );
	RefModule good1 (
		.clk,
		.enable,
		.S,
		.A,
		.B,
		.C,
		.Z(Z_ref) );
		
	TopModule top_module1 (
		.clk,
		.enable,
		.S,
		.A,
		.B,
		.C,
		.Z(Z_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_Z) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "Z", stats1.errors_Z, stats1.errortime_Z);
		else $display("Hint: Output '%s' has no mismatches.", "Z");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { Z_ref } === ( { Z_ref } ^ { Z_dut } ^ { Z_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (Z_ref !== ( Z_ref ^ Z_dut ^ Z_ref ))
		begin if (stats1.errors_Z == 0) stats1.errortime_Z = $time;
			stats1.errors_Z = stats1.errors_Z+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

