`ifndef APB_ENV_INCLUDED_
`define APB_ENV_INCLUDED_

class apb_env extends uvm_env;
	`uvm_component_utils(apb_env)

	apb_slave_agent agt_act;
	apb_slave_agent agt_pass;
	apb_scoreboard scb;
	apb_coverage cov;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(uvm_active_passive_enum)::set(this, "agt_passt", "is_active", UVM_PASSIVE);
		agt_act		= apb_slave_agent::type_id::create("agt_act",this);
		agt_pass	= apb_slave_agent::type_id::create("agt_pass",this);
		scb				= apb_scoreboard::type_id::create("scb",this);
		cov				= apb_coverage::type_id::create("cov",this);
	endfunction: build_phase	

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		/* agt_act.mon_act.mon_act_port.connect(scb.item_act_port); */
		/* agt_pass.mon_pass.mon_pass_port.connect(scb.item_pass_port); */
	
		/* agt_act.mon_act.mon_act_port.connect(cov.mon_act_cg_port); */
		/* agt_pass.mon_pass.mon_pass_port.connect(cov.analysis_export); */
	endfunction: connect_phase	
endclass: apb_env	

`endif
