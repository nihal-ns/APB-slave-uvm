`ifndef APB_SLAVE_SEQUENCER_INCLUDED_  
`define APB_SLAVE_SEQUENCER_INCLUDED_ 

class apb_slave_sequencer extends uvm_sequencer#(apb_slave_seq_item);
	`uvm_component_utils(apb_slave_sequencer)                

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

endclass: apb_slave_sequencer

`endif
