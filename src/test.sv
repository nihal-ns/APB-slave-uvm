`ifndef TEST_INCLUDED_  
`define TEST_INCLUDED_ 

class test extends uvm_test;
	`uvm_component_utils(test)

	apb_env env;
	apb_slave_sequence seq;

	function new(string name = "test", uvm_component parent = null);
		super.new(name, parent);
	endfunction: new	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = apb_env::type_id::create("env",this);
	  /* uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agt_act", "is_active", UVM_ACTIVE); */
    /* uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agt_pass", "is_active", UVM_PASSIVE); */
		seq = apb_slave_sequence::type_id::create("seq",this);
	endfunction: build_phase	

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(10)
			seq.start(env.agt_act.seqr);
		phase.drop_objection(this);
	endtask: run_phase

endclass: test	

`endif
