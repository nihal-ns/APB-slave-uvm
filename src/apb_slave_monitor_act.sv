`ifndef APB_SLAVE_MONITOR_ACT_INCLUDED_   
`define APB_SLAVE_MONITOR_ACT_INCLUDED_  

class apb_slave_monitor_act extends uvm_monitor;
	`uvm_component_utils(apb_slave_monitor_act)     

	virtual apb_intf vif;     
	uvm_analysis_port #(apb_slave_seq_item) mon_act_port;   

	function new(string name = "apb_slave_monitor_act", uvm_component parent);   
		super.new(name,parent);
	endfunction: new	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		 mon_act_port = new("mon_act_port",this);   
		if(!uvm_config_db#(virtual apb_intf)::get(this,"","vif",vif))  
			`uvm_fatal("NO_VIF","virtual interface failed to get from config");
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		forever begin
			apb_slave_seq_item item = apb_slave_seq_item::type_id::create("item");

			@(vif.mon_cb);
			wait (vif.PSELx && vif.PENABLE);  // should check again

			item.PADDR		= vif.PADDR;
			item.PSELx		= vif.PSELx;
			item.PENABLE	= vif.PENABLE;
			item.PWRITE		= vif.PWRITE;
			item.PWDATA		= vif.PWDATA;
			item.PSTRB		= vif.PSTRB;
			mon_act_port.write(item);

			if(item.PWRITE)
				`uvm_info(get_type_name,$sformatf("\nmonitor active write: enable:%0b |pwrite:%0b |psel:%0d |addr:%0d |wdata:%0d | strb:%0d",item.PENABLE, item.PWRITE, item.PSELx, item.PADDR, item.PWDATA, item.PSTRB),UVM_LOW)
			else
				`uvm_info(get_type_name,$sformatf("\nmonitor active read: enable:%0b |pwrite:%0b |psel:%0d |addr:%0d",item.PENABLE, item.PWRITE, item.PSELx, item.PADDR),UVM_LOW)

			wait(vif.PREADY);
			repeat(2)@(vif.mon_cb);
		end
	endtask: run_phase

endclass: apb_slave_monitor_act  

`endif
