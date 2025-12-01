program apb_slave_assertion (PCLK, PRESETn, PADDR, PSELx, PENABLE, PWRITE, PWDATA, PSTRB, PREADY, PRDATA, PSLVERR);
	input PCLK, PRESETn;
	input PSELx;
	input PENABLE;
	input PWRITE;
	input PREADY;
	input PSLVERR;
	input [`ADDR_WIDTH-1:0] PADDR;
	input [`WIDTH-1:0] PWDATA;
	input [`WIDTH-1:0] PRDATA;
	input [3:0] PSTRB;

	//////////////////////////////////
	///     Signal Valid check     ///
	//////////////////////////////////
	
	//Pselx valid
	property valid_sel;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PSELx);
	endproperty
	
	// Penable valid
	property valid_ena;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PENABLE);
	endproperty

	// Pwrite valid
	property valid_write;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PWRITE);
	endproperty

	// Pready valid
	property valid_ready;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PREADY);
	endproperty

	// PSLVERR valid
	property valid_error;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PSLVERR);
	endproperty

	// PADDR valid
	property valid_paddr;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PADDR);
	endproperty

	// PWDATA valid
	property valid_wdata;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PWDATA);
	endproperty

	// PRDATA valid
	property valid_rdata;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PRDATA);
	endproperty

	// PSTRB valid
	property valid_strb;
		@(posedge PCLK) disable iff (!PRESETn) !$isunknown(PSTRB);
	endproperty

	assert property(valid_sel)
		$info("Psel is valid");
	else
		$info("Psel is invalid");
	
	assert property(valid_ena)
		$info("Penable is valid");
	else
		$info("Penable is invalid");
	
	assert property(valid_write)
		$info("Pwrite is valid");
	else
		$info("Pwrite is invalid");
	
	assert property(valid_ready)
		$info("Pready is valid");
	else
		$info("Pready is invalid");
	
	assert property(valid_error)
		$info("error is valid");
	else
		$info("error is invalid");
	
	assert property(valid_paddr)
		$info("Paddr is valid");
	else
		$info("Paddr is invalid");
	
	assert property(valid_wdata)
		$info("Pwdata is valid");
	else
		$info("Pwdata is invalid");
	
	assert property(valid_rdata)
		$info("Prdata is valid");
	else
		$info("Prdata is invalid");

	assert property(valid_strb)
		$info("Pstrb is valid");
	else
		$info("Pstrb is invalid");

	/* property valid; */
	/* 	@(posedge PCLK) !PRESETn |-> !$isunknown({PSELx, PADDR, PENABLE, PWRITE, PWDATA, PREADY, PRDATA, PSLVERR, PSTRB}); */
	/* endproperty */
	
	/* assert property(valid) */
	/* 	$info("signal is valid"); */
	/* else */
	/* 	$info("signal is invalid"); */

	///////////////////////
	///  Timing checks  ///
	///////////////////////
	
	property ena_low;
		@(posedge PCLK) PREADY |=> !PENABLE;
	endproperty
endprogram
