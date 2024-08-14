`timescale 1 ps/1 ps
`define OK 12
`define INCORRECT 13


module stimulus_gen (
	input clk,
	output reg too_cold, too_hot, mode, fan_on,
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
		{too_cold, too_hot, mode, fan_on} <= 4'b0010;
		@(negedge clk);
		wavedrom_start("Winter");
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0010;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0010;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1010;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1011;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0010;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0011;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0010;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0110;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1110;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0111;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1111;
		@(negedge clk) wavedrom_stop();

		{too_cold, too_hot, mode, fan_on} <= 4'b0000;
		@(negedge clk);
		wavedrom_start("Summer");
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0000;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0000;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0100;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0101;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0000;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0001;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b0000;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1000;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1100;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1001;
			@(posedge clk) {too_cold, too_hot, mode, fan_on} <= 4'b1101;
		@(negedge clk) wavedrom_stop();
		
		repeat(200)
			@(posedge clk, negedge clk) {too_cold, too_hot, mode, fan_on} <= $random;
		
		#1 $finish;
	end
	
endmodule

module tb();

	typedef struct packed {
		int errors;
		int errortime;
		int errors_heater;
		int errortime_heater;
		int errors_aircon;
		int errortime_aircon;
		int errors_fan;
		int errortime_fan;

		int clocks;
	} stats;
	
	stats stats1;
	
	
	wire[511:0] wavedrom_title;
	wire wavedrom_enable;
	int wavedrom_hide_after_time;
	
	reg clk=0;
	initial forever
		#5 clk = ~clk;

	logic mode;
	logic too_cold;
	logic too_hot;
	logic fan_on;
	logic heater_ref;
	logic heater_dut;
	logic aircon_ref;
	logic aircon_dut;
	logic fan_ref;
	logic fan_dut;

	initial begin 
		$dumpfile("wave.vcd");
		$dumpvars(1, stim1.clk, tb_mismatch ,mode,too_cold,too_hot,fan_on,heater_ref,heater_dut,aircon_ref,aircon_dut,fan_ref,fan_dut );
	end


	wire tb_match;		// Verification
	wire tb_mismatch = ~tb_match;
	
	stimulus_gen stim1 (
		.clk,
		.* ,
		.mode,
		.too_cold,
		.too_hot,
		.fan_on );
	RefModule good1 (
		.mode,
		.too_cold,
		.too_hot,
		.fan_on,
		.heater(heater_ref),
		.aircon(aircon_ref),
		.fan(fan_ref) );
		
	TopModule top_module1 (
		.mode,
		.too_cold,
		.too_hot,
		.fan_on,
		.heater(heater_dut),
		.aircon(aircon_dut),
		.fan(fan_dut) );

	
	bit strobe = 0;
	task wait_for_end_of_timestep;
		repeat(5) begin
			strobe <= !strobe;  // Try to delay until the very end of the time step.
			@(strobe);
		end
	endtask	

	
	final begin
		if (stats1.errors_heater) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "heater", stats1.errors_heater, stats1.errortime_heater);
		else $display("Hint: Output '%s' has no mismatches.", "heater");
		if (stats1.errors_aircon) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "aircon", stats1.errors_aircon, stats1.errortime_aircon);
		else $display("Hint: Output '%s' has no mismatches.", "aircon");
		if (stats1.errors_fan) $display("Hint: Output '%s' has %0d mismatches. First mismatch occurred at time %0d.", "fan", stats1.errors_fan, stats1.errortime_fan);
		else $display("Hint: Output '%s' has no mismatches.", "fan");

		$display("Hint: Total mismatched samples is %1d out of %1d samples\n", stats1.errors, stats1.clocks);
		$display("Simulation finished at %0d ps", $time);
		$display("Mismatches: %1d in %1d samples", stats1.errors, stats1.clocks);
	end
	
	// Verification: XORs on the right makes any X in good_vector match anything, but X in dut_vector will only match X.
	assign tb_match = ( { heater_ref, aircon_ref, fan_ref } === ( { heater_ref, aircon_ref, fan_ref } ^ { heater_dut, aircon_dut, fan_dut } ^ { heater_ref, aircon_ref, fan_ref } ) );
	// Use explicit sensitivity list here. @(*) causes NetProc::nex_input() to be called when trying to compute
	// the sensitivity list of the @(strobe) process, which isn't implemented.
	always @(posedge clk, negedge clk) begin

		stats1.clocks++;
		if (!tb_match) begin
			if (stats1.errors == 0) stats1.errortime = $time;
			stats1.errors++;
		end
		if (heater_ref !== ( heater_ref ^ heater_dut ^ heater_ref ))
		begin if (stats1.errors_heater == 0) stats1.errortime_heater = $time;
			stats1.errors_heater = stats1.errors_heater+1'b1; end
		if (aircon_ref !== ( aircon_ref ^ aircon_dut ^ aircon_ref ))
		begin if (stats1.errors_aircon == 0) stats1.errortime_aircon = $time;
			stats1.errors_aircon = stats1.errors_aircon+1'b1; end
		if (fan_ref !== ( fan_ref ^ fan_dut ^ fan_ref ))
		begin if (stats1.errors_fan == 0) stats1.errortime_fan = $time;
			stats1.errors_fan = stats1.errors_fan+1'b1; end

	end

   // add timeout after 100K cycles
   initial begin
     #1000000
     $display("TIMEOUT");
     $finish();
   end

endmodule

