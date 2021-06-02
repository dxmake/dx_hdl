set project_name $::env(PROJECT_NAME)
set dx_hdl_dir $::env(DX_HDL_DIR)
set dx_project_path $dx_hdl_dir/project
set dx_library_path $dx_hdl_dir/library
set dx_scripts_path $dx_hdl_dir/scripts

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
