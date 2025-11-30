`ifndef APB_SLAVE_SEQ_ITEM_INCLUDED_  
`define APB_SLAVE_SEQ_ITEM_INCLUDED_ 

class apb_slave_seq_item extends uvm_sequence_item;    
	rand logic [`ADDR_WIDTH-1:0] PADDR;
	rand logic PSELx;
	rand logic PENABLE;
	rand logic PWRITE;
	rand logic [`WIDTH -1:0] PWDATA;
	rand logic [3:0] PSTRB;
	
	logic PREADY;
	logic [`WIDTH-1:0] PRDATA;
	logic PSLVERR;

	`uvm_object_utils_begin(apb_slave_seq_item)
		`uvm_field_int(PADDR, UVM_ALL_ON)
		`uvm_field_int(PSELx, UVM_ALL_ON)
		`uvm_field_int(PENABLE, UVM_ALL_ON)
		`uvm_field_int(PWRITE, UVM_ALL_ON)
		`uvm_field_int(PWDATA, UVM_ALL_ON)
		`uvm_field_int(PSTRB, UVM_ALL_ON)

		`uvm_field_int(PREADY, UVM_ALL_ON)
		`uvm_field_int(PRDATA, UVM_ALL_ON)
		`uvm_field_int(PSLVERR, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "apb_slave_seq_item"); 
		super.new(name);
	endfunction: new

endclass: apb_slave_seq_item

`endif
