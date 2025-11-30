`ifndef APB_SLAVE_SEQ_INCLUDED_  
`define APB_SLAVE_SEQ_INCLUDED_ 

class apb_slave_seq extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(apb_slave_seq)                   

	function new(string name = "apb_slave_seq");    
		super.new(name);
	endfunction: new

	virtual task body();
		req = apb_slave_seq_item::type_id::create("req");          // change the seq_item
		start_item(req);
		if(!req.randomize())
		begin
			`uvm_error(get_type_name(),"randomization failed");
		end
		req.print();
		finish_item(req);
	endtask: body

endclass: apb_slave_seq 

///////////////////////////////////
class wr_rd extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(wr_rd)

	function new(string name = "wr_rd");
		super.new(name);
	endfunction: new

	virtual task body();
    logic [`ADDR_WIDTH:0] written_address;

		`uvm_create(req)
		assert(req.randomize() with {
			req.PSELx  == 1;
			req.PWRITE == 1; // It's a write
			/* req.PENABLE == 1; */
		});
		`uvm_send(req) 

	// --- Store the address for the readback check ---
    written_address = req.PADDR;

		`uvm_create(req)
		assert(req.randomize() with {
			req.PSELx  == 1;
			req.PWRITE == 0; // It's a read
			/* req.PENABLE == 1; */
			req.PADDR  == written_address; // Read from the address we just wrote to
		});
		`uvm_send(req)
	endtask: body

endclass

`endif
