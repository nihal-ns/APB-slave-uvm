`ifndef APB_SLAVE_SEQ_INCLUDED_  
`define APB_SLAVE_SEQ_INCLUDED_ 

class apb_slave_seq extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(apb_slave_seq)                   

	function new(string name = "apb_slave_seq");    
		super.new(name);
	endfunction: new

	virtual task body();
		req = apb_slave_seq_item::type_id::create("req");   
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
////  write and read sequence  ////
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
			req.PSTRB == 9;
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
			req.PSTRB == 0;
		});
		`uvm_send(req)
	endtask: body

endclass

//////////////////////////////////////////////
////  Continuous write and read sequence  ////
//////////////////////////////////////////////
class write_read extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(write_read)
	bit [8:0] read_addr;
	logic [8:0] write_addr [20:0];
	int i;

	function new(string name = "write_read");
		super.new(name);
	endfunction: new
	
	virtual task body();
		repeat(5) begin 
			`uvm_do_with(req, {
				req.PSELx  == 1;
				req.PWRITE == 1;
			}) 
			write_addr[i] = req.PADDR;
			i++;
		end

		repeat(5) begin
			i--;
			read_addr = write_addr[i];
			`uvm_do_with(req, {
				req.PSELx  == 1;
				req.PWRITE == 0;
				req.PADDR == read_addr;
				req.PSTRB == 0;
			}) 
		end
	endtask: body

endclass: write_read

///////////////////////////////////
////  write override sequence  ////
///////////////////////////////////
class write_override extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(write_override)
	bit [8:0] read_addr;

	function new(string name = "write_override");
		super.new(name);
	endfunction: new
	
	virtual task body(); 
	// first write to some address
		`uvm_do_with(req, {
			req.PSELx  == 1;
			req.PWRITE == 1;
		}) 
		read_addr = req.PADDR; // store that address here

		`uvm_do_with(req, {
			req.PSELx  == 1;
			req.PWRITE == 1;
			req.PADDR == read_addr;  // pass same address to overwrite the data
		}) 

		// read from the overriden address
		`uvm_do_with(req, {
			req.PSELx  == 1;
			req.PWRITE == 0;
			req.PADDR == read_addr;
			req.PSTRB == 0;
		}) 
	endtask: body

endclass: write_override

///////////////////////////////////
////  read data error sequence ////
///////////////////////////////////
class read_error extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(read_error)

	function new(string name = "read_error");
		super.new(name);
	endfunction: new

	virtual task body();
	// read from any address
		`uvm_do_with(req, {
			req.PSELx  == 1;
			req.PWRITE == 0;
			req.PSTRB == 0;
		})

		`uvm_do_with(req, {
			req.PSELx  == 1;
			req.PWRITE == 1;
			req.PADDR inside {8'h10,8'h11};
			req.PSTRB == 0;
		})
	endtask: body

endclass: read_error

///////////////////////////////////
////    regression sequence    ////
///////////////////////////////////
class regression_seq extends uvm_sequence#(apb_slave_seq_item);
	`uvm_object_utils(regression_seq)

	wr_rd						seq_1;
	write_read			seq_2;
	write_override	seq_3;
	read_error			seq_4;

	function new(string name = "regression_seq");
		super.new(name);
	endfunction: new

	virtual task body();
	`uvm_info(get_type_name(),$sformatf("\n regression sequence started \n"), UVM_LOW);
		`uvm_do(seq_1)
		`uvm_do(seq_2)
		`uvm_do(seq_3)
		`uvm_do(seq_4)
	endtask: body

endclass: regression_seq

`endif
