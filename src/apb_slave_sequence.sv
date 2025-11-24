`ifndef _SEQ_INCLUDED_  //	CHANGE THE NAME
`define _SEQ_INCLUDED_  // CHANGE THE NAME

class _sequence extends uvm_sequence#(_seq_item); // CHANGE THE NAME
	`uvm_object_utils(_sequence)                    // CHANGE

	function new(string name = "_sequence");        // CHANGE
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

endclass: _sequence  // CHANGE THE NAME

`endif
