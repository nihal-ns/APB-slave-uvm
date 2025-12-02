`ifndef APB_SCOREBOARD_INCLUDED_
`define APB_SCOREBOARD_INCLUDED_

`uvm_analysis_imp_decl(_mon_pass)
`uvm_analysis_imp_decl(_mon_act)

class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)

	uvm_analysis_imp_mon_act #(apb_slave_seq_item, apb_scoreboard) item_act_port;
	uvm_analysis_imp_mon_pass #(apb_slave_seq_item, apb_scoreboard) item_pass_port;

	virtual apb_slave_intf vif;
	apb_slave_seq_item act_packet_q[$];
	apb_slave_seq_item pass_packet_q[$];
	bit [`WIDTH-1:0] mem[*];
	int MATCH, MISMATCH;

  bit [(`WIDTH/8)-1:0] stored_strobes[int];

	function new(string name = "apb_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		item_act_port = new("item_act_port",this);
		item_pass_port = new("item_pass_port",this);
	endfunction: build_phase

	virtual function void write_mon_act(apb_slave_seq_item pkt);
		`uvm_info(get_type_name(), "Received input packet ", UVM_DEBUG)
		act_packet_q.push_back(pkt);
	endfunction: write_mon_act

	virtual function void write_mon_pass(apb_slave_seq_item pkt);
		`uvm_info(get_type_name(), "Received output packet ", UVM_DEBUG)
		pass_packet_q.push_back(pkt);
	endfunction: write_mon_pass

	virtual task run_phase(uvm_phase phase);
		apb_slave_seq_item act_pkt, pass_pkt;
    forever begin
			fork
				begin
					wait(act_packet_q.size() > 0);
					act_pkt  = act_packet_q.pop_front();
				end

				begin
					wait(pass_packet_q.size() > 0);
					pass_pkt = pass_packet_q.pop_front();
				end
			join
			compare(act_pkt,pass_pkt);
			$display("\n==========================================================================================================\n");
		end
	endtask: run_phase

	
	virtual task compare(apb_slave_seq_item act_pkt, pass_pkt);
		int num_bytes = `WIDTH / 8;
		bit [(`WIDTH/8)-1:0] current_strobe;
		bit byte_match;

		if (act_pkt.PWRITE) begin : write_transaction
			if (!pass_pkt.PSLVERR) begin
				// Store Data and Strobe directly (No loops, no exists checks)
				mem[act_pkt.PADDR] = act_pkt.PWDATA;
				stored_strobes[act_pkt.PADDR] = act_pkt.PSTRB;

				`uvm_info(get_type_name(), $sformatf("WRITE SUCCESS: Addr:%0d Data:%0d Strobe:%b", act_pkt.PADDR, mem[act_pkt.PADDR], act_pkt.PSTRB), UVM_MEDIUM)
			end	
			else begin
				`uvm_info(get_type_name(), $sformatf("WRITE ERROR (PSLVERR): Addr:%0d", act_pkt.PADDR), UVM_MEDIUM)
			end
		end 
		else begin : read_transaction
			if (!pass_pkt.PSLVERR) begin
			// Retrieve the Strobe (Returns 0 if address not found)
			current_strobe = stored_strobes[act_pkt.PADDR];
			byte_match = 1;

			// Loop through bytes and compare ONLY valid ones
			for(int i=0; i<num_bytes; i++) begin
				if (current_strobe[i]) begin
					if (pass_pkt.PRDATA[(i*8) +: 8] !== mem[act_pkt.PADDR][(i*8) +: 8]) begin
						`uvm_error(get_type_name(), $sformatf("Byte %0d Mismatch! Addr:%0d Exp Byte:%h Got Byte:%h", i, act_pkt.PADDR, mem[act_pkt.PADDR][(i*8) +: 8], pass_pkt.PRDATA[(i*8) +: 8]))
						byte_match = 0;
					end
				end
			end

			if (byte_match) begin
				`uvm_info(get_type_name(), $sformatf("READ PASSED: Addr:%0d Mask:%b Data:%0d", act_pkt.PADDR, current_strobe, pass_pkt.PRDATA), UVM_LOW)
				MATCH++;
			end else begin
				MISMATCH++;
			end
		end else begin
			`uvm_info(get_type_name(), $sformatf("READ ERROR (PSLVERR): Addr:%0d", act_pkt.PADDR), UVM_MEDIUM)
		end
	end
	endtask: compare		
	
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
		$display("\n==========================================================================================================\n");
    `uvm_info("SCB", $sformatf("||| TOTAL MATCHES     : %0d |||", MATCH), UVM_NONE)
    `uvm_info("SCB", $sformatf("||| TOTAL MISSMATCHES : %0d |||", MISMATCH), UVM_NONE)
		$display("\n==========================================================================================================\n");
  endfunction: report_phase

endclass: apb_scoreboard

`endif
