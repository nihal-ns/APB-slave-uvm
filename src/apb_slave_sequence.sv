`ifndef APB_SLAVE_SEQ_INCLUDED_  
`define APB_SLAVE_SEQ_INCLUDED_ 

class apb_slave_seq extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(apb_slave_seq)                   

	function new(string name = "apb_slave_seq");    
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info(get_type_name(),$sformatf(" "), UVM_LOW)  // CHANGE 
		req = _seq_item::type_id::create("req");          // change the seq_item
		start_item(req);
		if(!req.randomize())
		begin
			`uvm_error(get_type_name(),"randomization failed");
		end
		req.print();
		finish_item(req);
	endtask: body

endclass: apb_slave_seq 

`endif
