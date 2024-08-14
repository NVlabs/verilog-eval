`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic [15:0] a,b,c,d,e,f,g,h,i,
	output logic [3:0] sel,
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
		{a,b,c,d,e,f,g,h,i,sel} <= { 16'ha, 16'hb, 16'hc, 16'hd, 16'he, 16'hf, 16'h11, 16'h12, 16'h13, 4'h0 };
		@(negedge clk) wavedrom_start();
			@(posedge clk) sel <= 4'h1;
			@(posedge clk) sel <= 4'h2;
			@(posedge clk) sel <= 4'h3;
			@(posedge clk) sel <= 4'h4;
			@(posedge clk) sel <= 4'h7;
			@(posedge clk) sel <= 4'h8;
			@(posedge clk) sel <= 4'h9;
			@(posedge clk) sel <= 4'ha;
			@(posedge clk) sel <= 4'hb;
		@(negedge clk) wavedrom_stop();
			
		repeat(200) @(negedge clk, posedge clk) begin
			{a,b,c,d,e,f,g,h,i,sel} <= {$random, $random, $random, $random, $random};
		end
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out;
		int errortime_out;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic [15:0] a;
	logic [15:0] b;
	logic [15:0] c;
	logic [15:0] d;
	logic [15:0] e;
	logic [15:0] f;
	logic [15:0] g;
	logic [15:0] h;
	logic [15:0] i;
	logic [3:0] sel;
	logic [15:0] out_ref;
	logic [15:0] out_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,c,d,e,f,g,h,i,sel,out_ref,out_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b,
		.c,
		.d,
		.e,
		.f,
		.g,
		.h,
		.i,
		.sel );
	RefModule good1 (
		.a,
		.b,
		.c,
		.d,
		.e,
		.f,
		.g,
		.h,
		.i,
		.sel,
		.out(out_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.c,
		.d,
		.e,
		.f,
		.g,
		.h,
		.i,
		.sel,
		.out(out_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out", stats1.errors_out, stats1.errortime_out);
		else $display("Hint: Output '%s' has no mismatches.", "out");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_ref } === ( { out_ref } ^ { out_dut } ^ { out_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_ref !== ( out_ref ^ out_dut ^ out_ref ))
		begin if (stats1.errors_out == 0) stats1.errortime_out = $time;
			stats1.errors_out = stats1.errors_out+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

