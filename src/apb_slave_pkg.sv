`ifndef APB_SLAVE_PKG_INCLUDED_
`define APB_SLAVE_PKG_INCLUDED_ 

`define WIDTH 8
`define ADDR_WIDTH 8

`include "uvm_macros.svh"

package apb_slave_pkg;
		import uvm_pkg::*;
	`include "apb_slave_seq_item.sv"
	`include "apb_slave_seq.sv"
	`include "apb_slave_sequencer.sv"
	`include "apb_slave_driver.sv"
	`include "apb_slave_monitor_act.sv"
	`include "apb_slave_monitor_pass.sv"
	`include "apb_slave_agent.sv"
	`include "apb_scoreboard.sv"
	`include "apb_subscriber.sv"
	`include "apb_env.sv"
	`include "test.sv"	
endpackage: apb_slave_pkg	

`endif
