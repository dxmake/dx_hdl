# instance: sys_ps8
ad_ip_instance zynq_ultra_ps_e sys_ps8

ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL0_ENABLE {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL1_ENABLE {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL2_ENABLE {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL3_ENABLE {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__FABRIC__RST {0}

# sys_ps8 DDR configuration
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__ENABLE               {1}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__SPEED_BIN            {DDR4_2400R}
ad_ip_parameter sys_ps8 CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200}
# DDR controller options
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__BUS_WIDTH   {64 Bit}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__ECC         {Enabled}
# DDR memory options
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__CL        {17}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__T_RCD     {16}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__T_RP      {16}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__CWL       {12}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__T_RC      {45.75}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__T_RAS_MIN {32.0}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__T_FAW     {30.0}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__DRAM_WIDTH      {16 Bits}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__BG_ADDR_COUNT   {1}
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__ROW_ADDR_COUNT  {16}
# DDR other options
ad_ip_parameter sys_ps8 CONFIG.PSU__DDRC__PARITY_ENABLE {1}

ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP0 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP1 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP2 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_ACP {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP0 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP1 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP2 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP3 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP4 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP5 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_GP6 {0}
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__S_AXI_ACE {0}

ad_ip_parameter sys_ps8 CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS33}
ad_ip_parameter sys_ps8 CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS33}
ad_ip_parameter sys_ps8 CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS33}
ad_ip_parameter sys_ps8 CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS33}
