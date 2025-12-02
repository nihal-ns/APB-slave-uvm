`ifndef APB_SUBSCRIBER_INCLUDED_
`define APB_SUBSCRIBER_INCLUDED_

`uvm_analysis_imp_decl(_mon_act_cg)

class apb_subscriber extends uvm_subscriber#(apb_slave_seq_item);
	`uvm_component_utils(apb_subscriber)
  
	uvm_analysis_imp_mon_act_cg#(apb_slave_seq_item, apb_subscriber) mon_act_cg_port;

	apb_slave_seq_item mon_pass_seq, mon_act_seq;
	real mon_act_cov, mon_pass_cov;

	// Input coverage
	covergroup apb_in_cvg ;
		PSEL_CP: coverpoint mon_act_seq.PSELx {
			bins sel_0 = {0};
			bins sel_1 = {1};
		}
		PENABLE_CP: coverpoint mon_act_seq.PENABLE {
			bins en_0 = {0};
			bins en_1 = {1};
		} 
		PWRITE_CP: coverpoint mon_act_seq.PWRITE {
			bins read = {0};
			bins write = {1};
		}
		PADDR_CP: coverpoint mon_act_seq.PADDR {
			option.auto_bin_max = 4;
		}
		PWDATA_CP: coverpoint mon_act_seq.PWDATA {
			option.auto_bin_max = 4;
		}
		PSTRB_CP: coverpoint mon_act_seq.PSTRB;
		PADDR_CP_x_PWDATA: cross PADDR_CP, PWDATA_CP;
	endgroup: apb_in_cvg

// Output coverage 
	covergroup apb_out_cvg;
		PREADY_CP: coverpoint mon_pass_seq.PREADY {
			bins ready_0 = {0};
			bins ready_1 = {1};
		}
		PSLVERR_CP: coverpoint mon_pass_seq.PSLVERR {
			bins error_0 = {0};
			bins error_1 = {1};
		}
		PRDATA_CP: coverpoint mon_pass_seq.PRDATA {
			option.auto_bin_max = 4;
		}
		PADDR_CP_x_PRDATA: cross mon_act_seq.PADDR , PRDATA_CP;
	endgroup: apb_out_cvg

	function new(string name = "apb_subscriber", uvm_component parent);
		super.new(name, parent);
		apb_in_cvg = new;
		apb_out_cvg = new;
	endfunction: new
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon_act_cg_port = new("mon_act_cg_port", this);
	endfunction: build_phase

	function void write(apb_slave_seq_item t);
		mon_pass_seq = t;
		apb_out_cvg.sample();
	endfunction: write

	function void write_mon_act_cg(apb_slave_seq_item t);
		mon_act_seq = t;
		apb_in_cvg.sample();
	endfunction: write_mon_act_cg

	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		mon_act_cov = apb_in_cvg.get_coverage();
		mon_pass_cov = apb_out_cvg.get_coverage();
	endfunction: extract_phase

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name, $sformatf("Input Coverage ------> %0.2f%%,", mon_act_cov), UVM_MEDIUM);
		`uvm_info(get_type_name, $sformatf("Output Coverage ------> %0.2f%%", mon_pass_cov), UVM_MEDIUM);
	endfunction: report_phase

endclass: apb_subscriber

`endif
