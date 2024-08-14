`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13
// hdlbits_prop {len: 5}


module stimulus_gen (
	input clk,
	output reg a,b,c,d,
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
		{a,b,c,d} = 4'h0;
		@(negedge clk);
		wavedrom_start("Exhaustive test");
		repeat(20) @(posedge clk, negedge clk)
			{d,c,b,a} <= {d,c,b,a} + 1'b1;
		wavedrom_stop();
		repeat(100) @(posedge clk, negedge clk) begin
			{a,b,c,d} <= $random;
		end
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out;
		int errortime_out;
		int errors_out_n;
		int errortime_out_n;

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
	logic d;
	logic out_ref;
	logic out_dut;
	logic out_n_ref;
	logic out_n_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,c,d,out_ref,out_dut,out_n_ref,out_n_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b,
		.c,
		.d );
	RefModule good1 (
		.a,
		.b,
		.c,
		.d,
		.out(out_ref),
		.out_n(out_n_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.c,
		.d,
		.out(out_dut),
		.out_n(out_n_dut) );

	
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
		if (stats1.errors_out_n) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_n", stats1.errors_out_n, stats1.errortime_out_n);
		else $display("Hint: Output '%s' has no mismatches.", "out_n");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_ref, out_n_ref } === ( { out_ref, out_n_ref } ^ { out_dut, out_n_dut } ^ { out_ref, out_n_ref } ) );
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
		if (out_n_ref !== ( out_n_ref ^ out_n_dut ^ out_n_ref ))
		begin if (stats1.errors_out_n == 0) stats1.errortime_out_n = $time;
			stats1.errors_out_n = stats1.errors_out_n+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

