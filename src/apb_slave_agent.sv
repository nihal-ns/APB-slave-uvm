`ifndef APB_SLAVE_AGENT_INCLUDED_
`define APB_SLAVE_AGENT_INCLUDED_

class apb_slave_agent extends uvm_agent;
	`uvm_component_utils(apb_slave_agent)
	
	apb_slave_driver drv;
	apb_slave_monitor_act mon_act;
	apb_slave_monitor_pass mon_pass;
	apb_slave_sequencer seqr;

	function new(string name = "apb_slave_agent",uvm_component parent);
		super.new(name,parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(get_is_active == UVM_ACTIVE) begin
			drv = driver::type_id::create("drv",this);
			seqr = sequencer::type_id::create("seqr",this);
		end
	mon_act = monitor_active::type_id::create("mon_act",this);
	endfunction: build_phase	

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction: connect_phase

endclass: apb_slave_agent

`endif
