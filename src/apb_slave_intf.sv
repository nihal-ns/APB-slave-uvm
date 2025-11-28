`ifndef APB_SLAVE_INTF_INCLUDED_
`define APB_SLAVE_INTF_INCLUDED_

interface apb_slave_intf (input bit PCLK, PRESETn);

	logic [`ADDR_WIDTH:0] PADDR;
	logic PSELx;
	logic PENABLE;
	logic PWRITE;
	logic [`WID-1:0] PWDATA;
	logic [3:0] PSTRB;
	
	logic PREADY;
	logic [`WID-1:0] PRDATA;
	logic PSLVERR;
	
	clocking drv_cb@(posedge PCLK);
		default input #0 output #0;
		input PRESETn;
		output PADDR, PSELx, PENABLE, PWRITE, PWDATA, PSTRB;
	endclocking

	clocking mon_cb@(posedge PCLK);
		default input #0 output #0;
		input PADDR, PSELx, PENABLE, PWRITE, PWDATA, PSTRB;
		input PREADY, PRDATA, PSLVERR;
	endclocking

	modport DRIVER(clocking drv_cb);
	modport MONITOR(clocking mon_cb);

endinterface: apb_slave_intf	

`endif
