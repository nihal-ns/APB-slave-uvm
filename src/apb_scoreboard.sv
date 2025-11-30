`ifndef APB_SCOREBOARD_INCLUDED_
`define APB_SCOREBOARD_INCLUDED_

`uvm_analysis_imp_decl(_mon_pass)
`uvm_analysis_imp_decl(_mon_act)

class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)

	uvm_analysis_imp_mon_act #(apb_slave_seq_item, apb_scoreboard) item_act_port;
	uvm_analysis_imp_mon_pass #(apb_slave-seq_item, apb_scoreboard) item_pass_port;

	virtual apb_slave_intf vif;
	apb_slave_seq_item act_packet_q[$];
	apb_slave_seq_item pass_packet_q[$];
	bit [`WIDTH-1:0] mem[*];

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
		act_packet_q.push_back(pkt);
	endfunction: write_mon_act

	virtual function void write_mon_pass(seq_item pkt);
		`uvm_info(get_type_name(), "Received output packet ", UVM_DEBUG)
		pass_packet_q.push_back(pkt);
	endfunction: write_mon_pass

	virtual task run_phase(uvm_phase phase);
		apb_slave_seq_item act_pkt, pass_pkt;
    forever begin
			fork

				//write transaction
				begin
					wait(act_packet_q.size() > 0);
					act_pkt = act_packet_q.pop_front();

					if (act_pkt.PWRITE == 1 && !pass_pkt.PSLVERR) begin
						mem[act_pkt.PADDR] = act_pkt.PWDATA;
            `uvm_info(get_type_name(), $sformatf("Wrote to address %0d with data %0d\n", act_pkt.PADDR, act_pkt.PWDATA), UVM_MEDIUM)
					end
				end
				
				// read transaction
				begin
					wait(pass_packet_q.size() > 0); 
          pass_pkt = pass_packet_q.pop_front();

					if(!pass_pkt.PSLVERR) begin
						if (pass_pkt.PRDATA == mem[act_pkt.PADDR]) begin
							`uvm_info(get_type_name(), $sformatf("SCOREBOARD PASSED: Addr: %0d, Expected: %0d, Got: %0d\n", act_pkt.PADDR, mem[act_pkt.PADDR], pass_pkt.PRDATA), UVM_LOW)
						end
						else begin
							`uvm_error(get_type_name(), $sformatf("SCOREBOARD FAILED: Addr: %0d, Expected: %0d, Got: %0d\n", act_pkt.PADDR, mem[act_pkt.PADDR], pass_pkt.PRDATA))
						end
					end
					else
						$display("Slave error detected");
				end
				$display("-----------------------------------------------------------------------------");
				end

			join
		end
	endtask: run_phase

endclass: apb_scoreboard

`endif
