
`ifndef APB_SLAVE_MONITOR_PASS_INCLUDED_   
`define APB_SLAVE_MONITOR_PASS_INCLUDED_  

class apb_slave_monitor_pass extends uvm_monitor;
	`uvm_component_utils(apb_slave_monitor_pass)     

	virtual apb_intf vif;     
	uvm_analysis_port #(apb_slave_seq_item) mon_pass_port;   

	function new(string name = "apb_slave_monitor_pass", uvm_component parent);   
		super.new(name,parent);
	endfunction: new	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		 mon_pass_port = new("mon_pass_port",this);   
		if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",vif))  
			`uvm_fatal("NO_VIF","virtual interface failed to get from config");
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		forever begin
			apb_slave_seq_item item = apb_slave_seq_item::type_id::create("item");

			@(vif.mon_cb);
			wait (vif.PSELx && vif.PENABLE && !vif.PWRITE && vif.PREADY); // should check again

			item.PREADY = vif.PREADY;
			item.PRDATA = vif.PRDATA;
			item.PSLVERR = vif.PSLVERR;
			mon_pass_port.write(item);

			`uvm_info(get_type_name,$sformatf("monitor passive: ready:%0b |rdata:%0d |error:%0b",item.PREADY, item.PRDATA, item.PSLVERR),UVM_LOW)
			repeat(2)@(vif.mon_cb);
		end
	endtask: run_phase

endclass: apb_slave_monitor_pass  

`endif
