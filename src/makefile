# --- UVM Variables ---
FILE ?= top.sv
TOP  ?= top
test ?= write_read_test  # Default test name, can be overridden from the command line

# --- Coverage Variables ---
COV_LOG_FILE   ?= slave_log.log
COV_DB_FILE    ?= coverage.ucdb
COV_REPORT_DIR ?= covReport

# --- Simulation Options ---
VERBOSITY ?= NORMAL
VSIM_EXTRA_OPTS =

# Set verbosity based on the VERBOSITY variable
ifeq ($(VERBOSITY), HIGH)
	VSIM_EXTRA_OPTS += +UVM_VERBOSITY=UVM_HIGH
endif
ifeq ($(VERBOSITY), DEBUG)
	VSIM_EXTRA_OPTS += +UVM_VERBOSITY=UVM_DEBUG
endif

# Set the testname if the test variable is provided
ifneq ($(test),)
	VSIM_EXTRA_OPTS += +UVM_TESTNAME=$(test)
endif


# --- Main Targets ---
.PHONY: all compile simulate clean h d coverage compile_cov simulate_cov report_cov

# Default target runs a normal UVM simulation
all: simulate

# --- Shortcut Targets ---
h:
	@$(MAKE) --no-print-directory simulate VERBOSITY=HIGH

d:
	@$(MAKE) --no-print-directory simulate VERBOSITY=DEBUG
	# --- End of Shortcut Targets ---

# --- UVM Simulation Targets ---
compile:
	@vlog -sv -l $(COV_LOG_FILE) apb_slave_pkg.sv $(FILE)

simulate: compile
	@echo "--- Running Simulation (Verbosity: $(VERBOSITY), Test: $(test)) ---"
	@vsim -c -l $(COV_LOG_FILE) $(TOP) $(VSIM_EXTRA_OPTS) -do "run -all ; quit"

# --- Coverage Targets ---
cov: 
	@vlog -sv +acc +cover +fcover -l $(COV_LOG_FILE) fifo_pkg.sv $(FILE)
	@vsim -vopt work.$(TOP) -voptargs=+acc=npr -assertdebug -l simulation.log -coverage $(VSIM_EXTRA_OPTS) -c -do "coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit"
	@vcover report -html $(COV_DB_FILE) -htmldir $(COV_REPORT_DIR) -details

# --- Clean Target ---
clean:
	@rm -rf transcript vsim.wlf work *.vstf *.log $(COV_LOG_FILE) $(COV_DB_FILE) $(COV_REPORT_DIR)
