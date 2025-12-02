`ifndef TEST_INCLUDED_  
`define TEST_INCLUDED_ 

class test extends uvm_test;
	`uvm_component_utils(test)

	apb_env env;
	apb_slave_seq seq;

	function new(string name = "test", uvm_component parent = null);
		super.new(name, parent);
	endfunction: new	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = apb_env::type_id::create("env",this);
	  uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agt_act", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agt_pass", "is_active", UVM_PASSIVE);
		seq = apb_slave_seq::type_id::create("seq",this);
	endfunction: build_phase	

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			repeat(10)
			seq.start(env.agt_act.seqr);
		phase.drop_objection(this);
	endtask: run_phase

endclass: test	

//////////////////////////////////////////
///   write first and then read        //
/////////////////////////////////////////
class write_read_test extends test;
	`uvm_component_utils(write_read_test)

	wr_rd seq;
	int no = 3;

	function new(string name = "write_read_test",uvm_component parent = null);
		super.new(name,parent);
		seq = wr_rd::type_id::create("seq");
	endfunction: new

	virtual task run_phase(uvm_phase phase);
		phase.phase_done.set_drain_time(this, 500ns);
		phase.raise_objection(this);
			repeat(no)
			seq.start(env.agt_act.seqr);
		phase.drop_objection(this);
  endtask: run_phase

endclass: write_read_test

////////////////////////////////////////////////////
///  continuous  write first and then read        //
///////////////////////////////////////////////////

class continuous_wr_rd_test extends test;
	`uvm_component_utils(continuous_wr_rd_test)

	write_read seq;

	function new(string name = "continuous_wr_rd_test",uvm_component parent = null);
		super.new(name,parent);
		seq = write_read::type_id::create("seq");
	endfunction: new

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(env.agt_act.seqr);
		phase.drop_objection(this);
  endtask: run_phase

endclass

//////////////////////////////////////////
///   write override and the read       //
/////////////////////////////////////////
class write_override_test extends test;
	`uvm_component_utils(write_override_test)

	write_override seq;

	function new(string name = "write_override_test",uvm_component parent = null);
		super.new(name,parent);
		seq = write_override::type_id::create("seq");
	endfunction: new

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(env.agt_act.seqr);
		phase.drop_objection(this);
  endtask: run_phase

endclass: write_override_test	

//////////////////////////////////////////
///   write override and the read       //
/////////////////////////////////////////
class read_error_test extends test;
	`uvm_component_utils(read_error_test)

	read_error seq;

	function new(string name = "read_error_test",uvm_component parent = null);
		super.new(name,parent);
		seq = read_error::type_id::create("seq");
	endfunction: new

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq.start(env.agt_act.seqr);
		phase.drop_objection(this);
	endtask: run_phase

endclass: read_error_data
`endif
