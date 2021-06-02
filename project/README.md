# dx_hdl_project

## A typical project structure

```
project_1
├── common
│   ├── xxx_bd.tcl
│   ├── xxx_constr.xdc
│   └── xxx.v
├── Makefile
├── README.md
├── sub_project_1
│   ├── Makefile
│   ├── system_constr.xdc
│   ├── system_design.tcl
│   ├── system_project.tcl
│   └── system_top.v
└── sub_project_2
```

### Makefile

```makefile
export DX_HDL_DIR := /home/julongjian/Repository/dx_hdl
export PROJECT_NAME := project_1

M_DEPS +=
LIB_DEPS +=

include ${DX_HDL_DIR}/scripts/project/project_xilinx.mk
```

### system_project.tcl

```tcl
set project_name $::env(PROJECT_NAME)
set dx_hdl_dir $::env(DX_HDL_DIR)
set dx_project_path $::env(DX_PROJECT_PATH)
set dx_library_path $::env(DX_LIBRARY_PATH)
set dx_scripts_path $::env(DX_SCRIPTS_PATH)

source $dx_scripts_path/project/env.tcl
source $dx_scripts_path/project/project_xilinx.tcl
source $dx_scripts_path/project/design.tcl

set p_device "xczu11eg-ffvf1517-2-i"
set sys_zynq 2

dx_project $project_name 0 [
]
dx_project_files $project_name [list \
  "system_top.v" \
  "system_constr.xdc" \
]
dx_project_bd $project_name
dx_project_run $project_name
```

- `project_xilinx.tcl` Defines a bunch of functions related to xilinx project.
- `design.tcl` Defines operate methods in BlockDesign.
