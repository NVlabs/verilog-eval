`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output logic a,b,
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
		@(negedge clk) {a,b} <= 0;
		wavedrom_start();
			@(posedge clk) {a,b} <= 0;
			@(posedge clk) {a,b} <= 1;
			@(posedge clk) {a,b} <= 2;
			@(posedge clk) {a,b} <= 3;
			@(negedge clk);
		wavedrom_stop();
		repeat(200) @(posedge clk, negedge clk)
		{a,b} <= $random;
		$finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_out_and;
		int errortime_out_and;
		int errors_out_or;
		int errortime_out_or;
		int errors_out_xor;
		int errortime_out_xor;
		int errors_out_nand;
		int errortime_out_nand;
		int errors_out_nor;
		int errortime_out_nor;
		int errors_out_xnor;
		int errortime_out_xnor;
		int errors_out_anotb;
		int errortime_out_anotb;

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
	logic out_and_ref;
	logic out_and_dut;
	logic out_or_ref;
	logic out_or_dut;
	logic out_xor_ref;
	logic out_xor_dut;
	logic out_nand_ref;
	logic out_nand_dut;
	logic out_nor_ref;
	logic out_nor_dut;
	logic out_xnor_ref;
	logic out_xnor_dut;
	logic out_anotb_ref;
	logic out_anotb_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,a,b,out_and_ref,out_and_dut,out_or_ref,out_or_dut,out_xor_ref,out_xor_dut,out_nand_ref,out_nand_dut,out_nor_ref,out_nor_dut,out_xnor_ref,out_xnor_dut,out_anotb_ref,out_anotb_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.a,
		.b );
	RefModule good1 (
		.a,
		.b,
		.out_and(out_and_ref),
		.out_or(out_or_ref),
		.out_xor(out_xor_ref),
		.out_nand(out_nand_ref),
		.out_nor(out_nor_ref),
		.out_xnor(out_xnor_ref),
		.out_anotb(out_anotb_ref) );
		
	TopModule top_module1 (
		.a,
		.b,
		.out_and(out_and_dut),
		.out_or(out_or_dut),
		.out_xor(out_xor_dut),
		.out_nand(out_nand_dut),
		.out_nor(out_nor_dut),
		.out_xnor(out_xnor_dut),
		.out_anotb(out_anotb_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_out_and) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_and", stats1.errors_out_and, stats1.errortime_out_and);
		else $display("Hint: Output '%s' has no mismatches.", "out_and");
		if (stats1.errors_out_or) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_or", stats1.errors_out_or, stats1.errortime_out_or);
		else $display("Hint: Output '%s' has no mismatches.", "out_or");
		if (stats1.errors_out_xor) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_xor", stats1.errors_out_xor, stats1.errortime_out_xor);
		else $display("Hint: Output '%s' has no mismatches.", "out_xor");
		if (stats1.errors_out_nand) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_nand", stats1.errors_out_nand, stats1.errortime_out_nand);
		else $display("Hint: Output '%s' has no mismatches.", "out_nand");
		if (stats1.errors_out_nor) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_nor", stats1.errors_out_nor, stats1.errortime_out_nor);
		else $display("Hint: Output '%s' has no mismatches.", "out_nor");
		if (stats1.errors_out_xnor) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_xnor", stats1.errors_out_xnor, stats1.errortime_out_xnor);
		else $display("Hint: Output '%s' has no mismatches.", "out_xnor");
		if (stats1.errors_out_anotb) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "out_anotb", stats1.errors_out_anotb, stats1.errortime_out_anotb);
		else $display("Hint: Output '%s' has no mismatches.", "out_anotb");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { out_and_ref, out_or_ref, out_xor_ref, out_nand_ref, out_nor_ref, out_xnor_ref, out_anotb_ref } === ( { out_and_ref, out_or_ref, out_xor_ref, out_nand_ref, out_nor_ref, out_xnor_ref, out_anotb_ref } ^ { out_and_dut, out_or_dut, out_xor_dut, out_nand_dut, out_nor_dut, out_xnor_dut, out_anotb_dut } ^ { out_and_ref, out_or_ref, out_xor_ref, out_nand_ref, out_nor_ref, out_xnor_ref, out_anotb_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (out_and_ref !== ( out_and_ref ^ out_and_dut ^ out_and_ref ))
		begin if (stats1.errors_out_and == 0) stats1.errortime_out_and = $time;
			stats1.errors_out_and = stats1.errors_out_and+1'b1; end
		if (out_or_ref !== ( out_or_ref ^ out_or_dut ^ out_or_ref ))
		begin if (stats1.errors_out_or == 0) stats1.errortime_out_or = $time;
			stats1.errors_out_or = stats1.errors_out_or+1'b1; end
		if (out_xor_ref !== ( out_xor_ref ^ out_xor_dut ^ out_xor_ref ))
		begin if (stats1.errors_out_xor == 0) stats1.errortime_out_xor = $time;
			stats1.errors_out_xor = stats1.errors_out_xor+1'b1; end
		if (out_nand_ref !== ( out_nand_ref ^ out_nand_dut ^ out_nand_ref ))
		begin if (stats1.errors_out_nand == 0) stats1.errortime_out_nand = $time;
			stats1.errors_out_nand = stats1.errors_out_nand+1'b1; end
		if (out_nor_ref !== ( out_nor_ref ^ out_nor_dut ^ out_nor_ref ))
		begin if (stats1.errors_out_nor == 0) stats1.errortime_out_nor = $time;
			stats1.errors_out_nor = stats1.errors_out_nor+1'b1; end
		if (out_xnor_ref !== ( out_xnor_ref ^ out_xnor_dut ^ out_xnor_ref ))
		begin if (stats1.errors_out_xnor == 0) stats1.errortime_out_xnor = $time;
			stats1.errors_out_xnor = stats1.errors_out_xnor+1'b1; end
		if (out_anotb_ref !== ( out_anotb_ref ^ out_anotb_dut ^ out_anotb_ref ))
		begin if (stats1.errors_out_anotb == 0) stats1.errortime_out_anotb = $time;
			stats1.errors_out_anotb = stats1.errors_out_anotb+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

