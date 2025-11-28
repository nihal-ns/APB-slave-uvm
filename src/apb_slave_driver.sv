`ifndef APB_SLAVE_DRIVER_INCLUDED_   
`define APB_SLAVE_DRIVER_INCLUDED_  

class apb_slave_driver extends uvm_driver#(apb_slave_seq_item); 
	`uvm_component_utils(apb_slave_driver)              

	virtual apb_slave_intf vif;  

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual apb_slave_intf)::get(this,"","vif",vif)) begin   
			`uvm_fatal("NO_VIF","virtual interface failed to get from config")       
		end
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
		end
	endtask: run_phase
	
	virtual task drive;
		// ------------------------------------
		// 1. SETUP Phase: PSEL=1, PENABLE=0
		// ------------------------------------
		@(vif.drv_cb);
		vif.PSELx   <= req.PSELx;
		vif.PENABLE <= 0;
		vif.PADDR   <= req.PADDR;
		vif.PWRITE  <= req.PWRITE;
		vif.PSTRB		<= req.PSTRB;
		if (req.PWRITE) begin
			vif.PWDATA <= req.PWDATA;
		end
		`uvm_info(get_type_name,$sformatf("Driver SETUP: PSEL:%0b | PADDR:%0d | PWRITE:%0b",req.PSELx, req.PADDR, req.PWRITE),UVM_LOW)

		// ------------------------------------
		// 2. ACCESS Phase: PENABLE=1
		// ------------------------------------
		@(vif.drv_cb);
		vif.PENABLE <= 1;
		`uvm_info(get_type_name,$sformatf("Driver ACCESS: PENABLE:%0b",vif.PENABLE),UVM_LOW)

		// Wait for PREADY from the slave
		wait(vif.PREADY == 1);

		// ------------------------------------
		// 3. End Transaction
		// ------------------------------------
		@(vif.drv_cb);
		vif.PSELx   <= 0;
		vif.PENABLE <= 0;
    `uvm_info(get_type_name(),$sformatf("APB %s transfer completed: ADDR:%0d | DATA:%0d | STRB:%0d", (req.PWRITE ? "WRITE" : "READ"), req.PADDR, (req.PWRITE ? req.PWDATA : vif.PRDATA),vif.PSTRB), UVM_MEDIUM)	
	/* repeat(1)@(vif.drv_cb); */ // should check if this is needed or not	
	endtask: drive

endclass: apb_slave_driver	 

`endif
