# ==== Project Makefile for Xilinx ============================================

DX_PROJECT_PATH := $(DX_HDL_DIR)/project
DX_LIBRARY_PATH := $(DX_HDL_DIR)/library
DX_SCRIPTS_PATH := $(DX_HDL_DIR)/scripts

include $(DX_SCRIPTS_PATH)/quiet.mk

VIVADO := vivado -mode batch -source

CLEAN_TARGET := *.cache
CLEAN_TARGET += *.gen
CLEAN_TARGET += *.data
CLEAN_TARGET += *.xpr
CLEAN_TARGET += *.log
CLEAN_TARGET += *.jou
CLEAN_TARGET +=  xgui
CLEAN_TARGET += *.runs
CLEAN_TARGET += *.srcs
CLEAN_TARGET += *.sdk
CLEAN_TARGET += *.hw
CLEAN_TARGET += *.sim
CLEAN_TARGET += .Xil
CLEAN_TARGET += *.ip_user_files
CLEAN_TARGET += *.str
CLEAN_TARGET += mem_init_sys.txt
CLEAN_TARGET += *.csv

# Common dependencies that all projects have
M_DEPS += system_project.tcl
M_DEPS += system_design.tcl
M_DEPS += system_top.v
M_DEPS += $(wildcard system_constr.xdc) # Not all projects have this file
M_DEPS += $(DX_SCRIPTS_PATH)/project/project_xilinx.tcl
M_DEPS += $(DX_SCRIPTS_PATH)/project/env.tcl
M_DEPS += $(DX_SCRIPTS_PATH)/project/design.tcl

M_DEPS += $(foreach dep,$(LIB_DEPS),$(DX_LIBRARY_PATH)/$(dep)/component.xml)

.PHONY: all lib clean clean-all
all: lib $(PROJECT_NAME).sdk/system_top.xsa

clean:
	-rm -f reference.dcp
	$(call clean, \
		$(CLEAN_TARGET), \
		$(HL)$(PROJECT_NAME)$(NC) project)

clean-all: clean
	@for lib in $(LIB_DEPS); do \
		$(MAKE) -C $(DX_LIBRARY_PATH)/$${lib} clean; \
	done

MODE ?= "default"

$(PROJECT_NAME).sdk/system_top.xsa: $(M_DEPS)
	@if [ $(MODE) = incr ]; then \
		if [ -f */impl_1/system_top_routed.dcp ]; then \
			echo Found previous run result at `ls */impl_1/system_top_routed.dcp`; \
			cp -u */impl_1/system_top_routed.dcp ./reference.dcp ; \
		fi; \
		if [ -f ./reference.dcp ]; then \
			echo Using reference checkpoint for incremental compilation; \
		fi; \
	else \
		rm -f reference.dcp; \
	fi;
	-rm -rf $(CLEAN_TARGET)
	$(call build, \
		$(VIVADO) system_project.tcl, \
		$(PROJECT_NAME)_vivado.log, \
		$(HL)$(PROJECT_NAME)$(NC) project)

lib:
	@for lib in $(LIB_DEPS); do \
		$(MAKE) -C $(DX_LIBRARY_PATH)/$${lib} xilinx || exit $$?; \
	done
