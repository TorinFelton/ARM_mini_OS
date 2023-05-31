//Verilog HDL for "COMP22712", "HalveClockSpeed" "functional"


module HalveClockSpeed (input clk, output reg halve_clk );


	always @ (posedge clk)
	begin
		halve_clk = ~halve_clk; 
		
	end

endmodule
