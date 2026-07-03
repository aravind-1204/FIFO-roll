TOP_MOD := tb_fifo
TOP_LOC := testbench

FILES := files.f 

BIN_LOC := bin
BIN_NAME := tb_fifo.o

DUMP_LOC := sim
DUMP_FILE := tb_fifo.vcd

SCRIPT_LOC := scripts
VERIFY_SCRIPT := compare_testfiles.py

lint:
	verilator --lint-only -Wall -f files.f --top-module $(TOP_MOD) $(TOP_LOC)/$(TOP_MOD).sv

compile: | $(BIN_LOC)
	iverilog -f $(FILES) -s $(TOP_MOD) $(TOP_LOC)/$(TOP_MOD).sv -o $(BIN_LOC)/$(BIN_NAME) -g2012

run: compile | $(DUMP_LOC)
	vvp $(BIN_LOC)/$(BIN_NAME) +DUMPFILE=$(DUMP_LOC)/$(DUMP_FILE) +FAST_WRITE

verify: run
	python3 $(SCRIPT_LOC)/$(VERIFY_SCRIPT)

$(BIN_LOC):
	mkdir -r $@

$(DUMP_LOC):
	mkdir -p $@

all:
	make lint
	make compile
	make run 
	make verify
.PHONY: lint compile run all verify