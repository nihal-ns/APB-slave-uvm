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

		// if removed both agent will be active, i don't why
		if(!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
			`uvm_error("No pass", $sformatf("get failed from the config",) )
		end
		
		if(get_is_active == UVM_ACTIVE) begin
			drv = apb_slave_driver::type_id::create("drv",this);
			seqr = apb_slave_sequencer::type_id::create("seqr",this);
			mon_act = apb_slave_monitor_act::type_id::create("mon_act",this);
		end
		else begin
			mon_pass = apb_slave_monitor_pass::type_id::create("mon_pass",this);
		end

	endfunction: build_phase	

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(get_is_active == UVM_ACTIVE) begin
			drv.seq_item_port.connect(seqr.seq_item_export);
		end
	endfunction: connect_phase

endclass: apb_slave_agent

`endif
