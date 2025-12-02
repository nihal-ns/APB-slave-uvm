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
		
		if(act_pkt.PWRITE) begin : write_transaction

			////////////////////////////////////////////
			//			Write transaction part            //
			////////////////////////////////////////////
			if(!pass_pkt.PSLVERR) begin : write_pass
			
				// strobe part
				/* for(int i=0; i<4; i++) begin */
				/* 	if(act_pkt.PSTRB[i]) begin */
				/* 		mem[act_pkt.PADDR][(i*8) +: 8] = act_pkt.PWDATA[(i*8) +: 8]; */
				/* 	end */
				/* end */

				mem[act_pkt.PADDR] = act_pkt.PWDATA;

				/* `uvm_info(get_type_name(), $sformatf("WRITE SUCCESS: Addr:%0d Data:%0d Strobe:%b", act_pkt.PADDR, mem[act_pkt.PADDR], act_pkt.PSTRB), UVM_MEDIUM) */
				`uvm_info(get_type_name(), $sformatf("WRITE SUCCESS: Addr:%0d Data:%0d ", act_pkt.PADDR, mem[act_pkt.PADDR]), UVM_MEDIUM)
				end : write_pass
				else begin : write_fail
					`uvm_info(get_type_name(), $sformatf("WRITE ERROR (PSLVERR): Addr:%0d", act_pkt.PADDR), UVM_MEDIUM)
				end : write_fail
			
		end : write_transaction

		////////////////////////////////////////////
		//				read transaction part           //
		////////////////////////////////////////////
		else begin : read_transaction
			if (!pass_pkt.PSLVERR) begin : read_pass

				if (pass_pkt.PRDATA == mem[act_pkt.PADDR]) begin : read_data_pass
					`uvm_info(get_type_name(), $sformatf("READ PASSED: Addr:%0d Expected:%0d Got:%0d", act_pkt.PADDR, mem[act_pkt.PADDR], pass_pkt.PRDATA), UVM_LOW)
					MATCH++;
				end : read_data_pass
				else begin : read_data_fail
					`uvm_error(get_type_name(), $sformatf("READ FAILED: Addr:%0d Expected:%0d Got:%0d", act_pkt.PADDR, mem[act_pkt.PADDR], pass_pkt.PRDATA))
					MISMATCH++;
				end : read_data_fail
			end : read_pass
			else begin : read_fail
				`uvm_info(get_type_name(), $sformatf("READ ERROR (PSLVERR): Addr:%0d", act_pkt.PADDR), UVM_MEDIUM)
			end : read_fail

		end : read_transaction
	
	endtask: compare

	// version one ==============================================================================================//
	//
	/* virtual task run_phase(uvm_phase phase); */
	/* 	apb_slave_seq_item act_pkt, pass_pkt; */
	/* 	logic [`WIDTH-1:0] expected_data; */

	/* 	forever begin */
	/* 		wait(act_packet_q.size() > 0 && pass_packet_q.size() > 0); */

	/* 		act_pkt  = act_packet_q.pop_front(); */
	/* 		pass_pkt = pass_packet_q.pop_front(); */

	/* 		if (act_pkt.PWRITE) begin */
	/* 			// --- WRITE TRANSACTION --- */
	/* 			if (!pass_pkt.PSLVERR) begin */
					
	/* 				for(int i=0; i<4; i++) begin */
	/* 					if(act_pkt.PSTRB[i]) begin */
	/* 						mem[act_pkt.PADDR][(i * (`WIDTH/4)) +: (`WIDTH/4)] = act_pkt.PWDATA[(i * (`WIDTH/4)) +: (`WIDTH/4)]; */
	/* 					end */
	/* 				end */

	/* 				`uvm_info(get_type_name(), $sformatf("WRITE SUCCESS: Addr:0x%0h Data:0x%0h Strobe:%b", act_pkt.PADDR, mem[act_pkt.PADDR], act_pkt.PSTRB), UVM_MEDIUM) */
	/* 			end */ 
	/* 			else begin */
	/* 				`uvm_info(get_type_name(), $sformatf("WRITE ERROR (PSLVERR): Addr:0x%0h", act_pkt.PADDR), UVM_MEDIUM) */
	/* 			end */
	/* 		end */ 
	/* 		else begin */
	/* 			// --- READ TRANSACTION --- */
	/* 			if (!pass_pkt.PSLVERR) begin */

	/* 				if (pass_pkt.PRDATA == expected_data) begin */
	/* 					`uvm_info(get_type_name(), $sformatf("READ PASSED: Addr:0x%0h Expected:0x%0h Got:0x%0h", act_pkt.PADDR, expected_data, pass_pkt.PRDATA), UVM_LOW) */
	/* 				end */ 
	/* 				else begin */
	/* 					`uvm_error(get_type_name(), $sformatf("READ FAILED: Addr:0x%0h Expected:0x%0h Got:0x%0h", act_pkt.PADDR, expected_data, pass_pkt.PRDATA)) */
	/* 				end */
	/* 			end */ 
	/* 			else begin */
	/* 				`uvm_info(get_type_name(), $sformatf("READ ERROR (PSLVERR): Addr:0x%0h", act_pkt.PADDR), UVM_MEDIUM) */
	/* 			end */
	/* 		end */
			
	/* 		$display("-----------------------------------------------------------------------------"); */
	/* 	end */
	/* endtask: run_phase */

	// version two ==============================================================================================//
/* 		virtual task run_phase(uvm_phase phase); */
/* 		apb_slave_seq_item act_pkt, pass_pkt; */
/*     forever begin */
/* 			fork */

/* 				//write transaction */
/* 				begin : write_start */
/* 					wait(act_packet_q.size() > 0); */
/* 					act_pkt = act_packet_q.pop_front(); */

/* 					if (act_pkt.PWRITE == 1 && !pass_pkt.PSLVERR) begin : if_write */
/* 						mem[act_pkt.PADDR] = act_pkt.PWDATA; */
/*             `uvm_info(get_type_name(), $sformatf("Wrote to address %0d with data %0d\n", act_pkt.PADDR, act_pkt.PWDATA), UVM_MEDIUM) */
/* 					end : if_write */
/* 				end : write_start */

/* 				// read transaction */
/* 				begin : read_start */
/* 					wait(pass_packet_q.size() > 0); */
/*           pass_pkt = pass_packet_q.pop_front(); */

/* 					if(!pass_pkt.PSLVERR) begin : if_error */
/* 						if (pass_pkt.PRDATA == mem[act_pkt.PADDR]) begin : if_read */
/* 							`uvm_info(get_type_name(), $sformatf("SCOREBOARD PASSED: Addr: %0d, Expected: %0d, Got: %0d\n", act_pkt.PADDR, mem[act_pkt.PADDR], pass_pkt.PRDATA), UVM_LOW) */
/* 						end : if_read */
/* 						else begin : else_read */
/* 							`uvm_error(get_type_name(), $sformatf("SCOREBOARD FAILED: Addr: %0d, Expected: %0d, Got: %0d\n", act_pkt.PADDR, mem[act_pkt.PADDR], pass_pkt.PRDATA)) */
/* 						end : else_read */
/* 					end : if_error */
/* 					else */
/* 						$display("Slave error detected"); */
/* 				$display("-----------------------------------------------------------------------------"); */
/* 				end : read_start */

/* 			join */
/* 		end */
/* 	endtask: run_phase */


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
		$display("\n==========================================================================================================\n");
    `uvm_info("SCB", $sformatf("||| TOTAL MATCHES     : %0d |||", MATCH), UVM_NONE)
    `uvm_info("SCB", $sformatf("||| TOTAL MISSMATCHES : %0d |||", MISMATCH), UVM_NONE)
		$display("\n==========================================================================================================\n");
  endfunction

endclass: apb_scoreboard

`endif
