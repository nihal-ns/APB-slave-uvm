`ifndef APB_SCOREBOARD_INCLUDED_
`define APB_SCOREBOARD_INCLUDED_

`uvm_analysis_imp_decl(_mon_pass)
`uvm_analysis_imp_decl(_mon_act)

class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)

	uvm_analysis_imp_mon_act #(apb_slave_seq_item, apb_scoreboard) item_act_port;
	uvm_analysis_imp_mon_pass #(apb_slave-seq_item, apb_scoreboard) item_pass_port;

	virtual apb_slave_intf vif;

	function new(string name = "apb_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		item_act_port = new("item_act_port",this);
		item_pass_port = new("item_pass_port",this);
	endfunction: build_phase

	virtual function void write_mon_act(seq_item pkt);
		`uvm_info(get_type_name(), "Received input packet ", UVM_DEBUG)
		/* mon_act_packet_q.push_back(pkt); */
	endfunction: write_mon_act

	virtual function void write_mon_pass(seq_item pkt);
		`uvm_info(get_type_name(), "Received output packet ", UVM_DEBUG)
		/* mon_pass_packet_q.push_back(pkt); */
	endfunction: write_mon_pass

	virtual task run_phase(uvm_phase phase);
    forever begin

		end
	endtask: run_phase

endclass: apb_scoreboard

`endif
