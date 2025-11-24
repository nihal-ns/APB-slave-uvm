`ifndef APB_SLAVE_PKG_INCLUDED_
`define APB_SLAVE_PKG_INCLUDED_ 

`define WIDTH 32
`define ADDR_WIDTH 32

package apb_slave_pkg;
	`include "apb_slave_seq_item.sv"
	`include "apb_slave_sequence.sv"
	`include "apb_slave_sequencer.sv"
	`include "slave_driver.sv"
	`include "slave_monitor.sv"
	`include "slave_agent.sv"
	`include "slave_scoreboard.sv"
	`include "slave_coverage.sv"
	`include "slave_env.sv"
	`include "test.sv"	
endpackage: apb_slave_pkg	

`endif
