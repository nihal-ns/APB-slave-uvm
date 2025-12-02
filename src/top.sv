`define WIDTH 32
`define ADDR_WIDTH 8

`include "uvm_macros.svh"
`include "apb_intf.sv"
`include "apb_slave_pkg.sv"
`include "apb.v"
`include "apb_slave_assertion.sv"

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
		.clk(PCLK),
		.rst_n(PRESETn),
		.paddr(intf.PADDR),
		.psel(intf.PSELx),
		.penable(intf.PENABLE),
		.pwrite(intf.PWRITE),
		.pwdata(intf.PWDATA),
		.pready(intf.PREADY),
		.prdata(intf.PRDATA),
		.pslverr(intf.PSLVERR),
		.pstrb(intf.PSTRB)
		);

	bind intf apb_slave_assertion ASSERT(.*); 

	initial begin
		uvm_config_db#(virtual apb_intf)::set(null,"*","vif",intf);
	end

	initial begin
		run_test();
		#100 $finish;
	end
endmodule	
