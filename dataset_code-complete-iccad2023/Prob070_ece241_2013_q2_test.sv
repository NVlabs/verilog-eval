`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic a, b, c, d,
	output reg[511:0] wavedrom_title,
	output reg wavedrom_enable,
	input tb_match
);

// Add two ports to module stimulus_gen:
//    output [511:0] wavedrom_title
//    output reg wavedrom_enable

	task wavedrom_start(input[511:0] title = "");
	endtask
	
	task wavedrom_stop;
		#1;
	endtask	



	bit fail = 0;
	bit fail1 = 0;
	always @(posedge clk, negedge clk)
		if (!tb_match)
			fail = 1;

	initial begin
		@(posedge clk) {a,b,c,d} <= 0;
		@(posedge clk) {a,b,c,d} <= 1;
		@(posedge clk) {a,b,c,d} <= 2;
		@(posedge clk) {a,b,c,d} <= 4;
		@(posedge clk) {a,b,c,d} <= 5;
		@(posedge clk) {a,b,c,d} <= 6;
		@(posedge clk) {a,b,c,d} <= 7;
		@(posedge clk) {a,b,c,d} <= 9;
		@(posedge clk) {a,b,c,d} <= 10;
		@(posedge clk) {a,b,c,d} <= 13;
		@(posedge clk) {a,b,c,d} <= 14;
		@(posedge clk) {a,b,c,d} <= 15;
		@(posedge clk) fail1 = fail;
		
		
				
		
		//@(negedge clk) wavedrom_start();
			for (int i=0;i<16;i++)
				@(posedge clk)
					{a,b,c,d} <= i;
		//@(negedge clk) wavedrom_stop();
		
		repeat(50) @(posedge clk, negedge clk)
			{a,b,c,d} <= $random;
			
		if (fail && ~fail1)
			$display("Hint: Your circuit passes on the 12 required input combinations, but doesn't match the don't-care cases. Are you using minimal SOP and POS?");

		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_sop;
		int errortime_out_sop;
		int errors_out_pos;
		int errortime_out_pos;

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
	logic out_sop_ref;
	logic out_sop_dut;
	logic out_pos_ref;
	logic out_pos_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,c,d,out_sop_ref,out_sop_dut,out_pos_ref,out_pos_dut );
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
		.out_sop(out_sop_ref),
		.out_pos(out_pos_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.c,
		.d,
		.out_sop(out_sop_dut),
		.out_pos(out_pos_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_sop) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_sop", stats1.errors_out_sop, stats1.errortime_out_sop);
		else $display("Hint: Output '%s' has no mismatches.", "out_sop");
		if (stats1.errors_out_pos) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_pos", stats1.errors_out_pos, stats1.errortime_out_pos);
		else $display("Hint: Output '%s' has no mismatches.", "out_pos");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_sop_ref, out_pos_ref } === ( { out_sop_ref, out_pos_ref } ^ { out_sop_dut, out_pos_dut } ^ { out_sop_ref, out_pos_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_sop_ref !== ( out_sop_ref ^ out_sop_dut ^ out_sop_ref ))
		begin if (stats1.errors_out_sop == 0) stats1.errortime_out_sop = $time;
			stats1.errors_out_sop = stats1.errors_out_sop+1'b1; end
		if (out_pos_ref !== ( out_pos_ref ^ out_pos_dut ^ out_pos_ref ))
		begin if (stats1.errors_out_pos == 0) stats1.errortime_out_pos = $time;
			stats1.errors_out_pos = stats1.errors_out_pos+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

