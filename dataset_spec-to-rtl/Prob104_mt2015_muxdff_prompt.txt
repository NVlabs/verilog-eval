
I would like you to implement a module named TopModule with the following
interface. All input and output ports are one bit unless otherwise
specified.

 - input  clk
 - input  L
 - input  q_in
 - input  r_in
 - output Q

Consider this Verilog module "full_module":

  module full_module (
      input [2:0] r,
      input L,
      input clk,
      output reg [2:0] q);

    always @(posedge clk) begin
      if (L) begin
        q <= r;
      end else begin
        q <= {q[1] ^ q[2], q[0], q[2]};
      end
    end

  endmodule

Note that q[2:0] is three bits wide, representing three flip-flops that can be
loaded from r when L is asserted. You want to factor full_module into a hierarchical
design, flipflop and 2:1 multiplexer are in a submodule "TopModule", and that submodule
will be instantiated three times in full_module code. Create the submodule called "TopModule".
You do not have to provide the revised full_module.

