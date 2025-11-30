`ifndef APB_INTF_INCLUDED_
`define APB_INTF_INCLUDED_

interface apb_intf (input bit PCLK, PRESETn);

	logic [`ADDR_WIDTH-1:0] PADDR;
	logic PSELx;
	logic PENABLE;
	logic PWRITE;
	logic [`WIDTH-1:0] PWDATA;
	logic [3:0] PSTRB;
	
	logic PREADY;
	logic [`WIDTH-1:0] PRDATA;
	logic PSLVERR;
	
	clocking drv_cb@(posedge PCLK);
		default input #0 output #0;
		input PRESETn;
		output PADDR, PSELx, PENABLE, PWRITE, PWDATA, PSTRB;
	endclocking: drv_cb

	clocking mon_cb@(posedge PCLK);
		default input #0 output #0;
		input PADDR, PSELx, PENABLE, PWRITE, PWDATA, PSTRB;
		input PREADY, PRDATA, PSLVERR;
	endclocking: mon_cb

	modport DRIVER(clocking drv_cb);
	modport MONITOR(clocking mon_cb);

endinterface: apb_intf	

`endif
