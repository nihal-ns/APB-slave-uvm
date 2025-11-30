`define WIDTH 8
`define ADDR_WIDTH 8

`include "uvm_macros.svh"
`include "apb_intf.sv"
`include "apb_slave_pkg.sv"
`include "apb.v"
/* `include "apb_slave_assertion.sv" */

import uvm_pkg::*;
import apb_slave_pkg::*;

module top;
	bit PCLK;
	bit PRESETn;

	always #5 PCLK = ~PCLK;
		
	initial begin
    PRESETn = 0;
		repeat(2)@(negedge PCLK);
		PRESETn = 1;
  end

	apb_intf intf(PCLK, PRESETn);

	apb_slave dut (
		.PCLK(PCLK),
		.PRESETn(PRESETn),
		.PADDR(intf.PADDR),
		.PSEL(intf.PSELx),
		.PENABLE(intf.PENABLE),
		.PWRITE(intf.PWRITE),
		.PWDATA(intf.PWDATA),
		.PREADY(intf.PREADY),
		.PRDATA(intf.PRDATA),
		.PSLVERR(intf.PSLVERR),
		.PSTRB(intf.PSTRB)
		);

	/* bind intf assertion ASSERT(.*); */ 

	initial begin
		uvm_config_db#(virtual apb_intf)::set(null,"*","vif",intf);
	end

	initial begin
		run_test("custom_test");
		#100 $finish;
	end
endmodule	
