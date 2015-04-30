
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set btn [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 btn ]
  set sw [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 sw ]

  # Create ports
  set LED_1 [ create_bd_port -dir O -from 2 -to 0 LED_1 ]
  set MISO [ create_bd_port -dir I MISO ]
  set MOSI [ create_bd_port -dir O MOSI ]
  set SCLK [ create_bd_port -dir O SCLK ]
  set SS [ create_bd_port -dir O SS ]

  # Create instance: Axis_Data, and set properties
  set Axis_Data [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 Axis_Data ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {10}  ] $Axis_Data

  # Create instance: CE, and set properties
  set CE [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 CE ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {1}  ] $CE

  # Create instance: PmodACL_Demo_1, and set properties
  set PmodACL_Demo_1 [ create_bd_cell -type ip -vlnv pct.edu:user:PmodACL_Demo:1.0 PmodACL_Demo_1 ]

  # Create instance: axis_sw, and set properties
  set axis_sw [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axis_sw ]
  set_property -dict [ list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {2}  ] $axis_sw

  # Create instance: btn, and set properties
  set btn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 btn ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {4}  ] $btn

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_IMPORT_BOARD_PRESET {/home/kevin/Downloads/ZYBO_zynq_def.xml} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0}  ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {8}  ] $processing_system7_0_axi_periph

  # Create instance: rst, and set properties
  set rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 rst ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {1}  ] $rst

  # Create instance: rst_processing_system7_0_50M, and set properties
  set rst_processing_system7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_50M ]

  # Create instance: sw, and set properties
  set sw [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 sw ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {4}  ] $sw

  # Create interface connections
  connect_bd_intf_net -intf_net btn_GPIO [get_bd_intf_ports btn] [get_bd_intf_pins btn/GPIO]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI] [get_bd_intf_pins sw/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins btn/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI] [get_bd_intf_pins rst/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins axis_sw/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins Axis_Data/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M07_AXI [get_bd_intf_pins CE/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net sw_GPIO [get_bd_intf_ports sw] [get_bd_intf_pins sw/GPIO]

  # Create port connections
  connect_bd_net -net MISO_1 [get_bd_ports MISO] [get_bd_pins PmodACL_Demo_1/SDI]
  connect_bd_net -net PmodACL_Demo_1_DataOut [get_bd_pins Axis_Data/gpio_io_i] [get_bd_pins PmodACL_Demo_1/DataOut]
  connect_bd_net -net PmodACL_Demo_1_LED [get_bd_ports LED_1] [get_bd_pins PmodACL_Demo_1/LED]
  connect_bd_net -net PmodACL_Demo_1_SCLK [get_bd_ports SCLK] [get_bd_pins PmodACL_Demo_1/SCLK]
  connect_bd_net -net PmodACL_Demo_1_SDO [get_bd_ports MOSI] [get_bd_pins PmodACL_Demo_1/SDO]
  connect_bd_net -net PmodACL_Demo_1_SS [get_bd_ports SS] [get_bd_pins CE/gpio_io_i] [get_bd_pins PmodACL_Demo_1/SS]
  connect_bd_net -net axis_sw_gpio_io_o [get_bd_pins PmodACL_Demo_1/SW] [get_bd_pins axis_sw/gpio_io_o]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins Axis_Data/s_axi_aclk] [get_bd_pins CE/s_axi_aclk] [get_bd_pins PmodACL_Demo_1/CLK] [get_bd_pins axis_sw/s_axi_aclk] [get_bd_pins btn/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst/s_axi_aclk] [get_bd_pins rst_processing_system7_0_50M/slowest_sync_clk] [get_bd_pins sw/s_axi_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_50M/ext_reset_in]
  connect_bd_net -net rst_gpio_io_o [get_bd_pins PmodACL_Demo_1/RST] [get_bd_pins rst/gpio_io_o]
  connect_bd_net -net rst_processing_system7_0_50M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_50M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_50M_peripheral_aresetn [get_bd_pins Axis_Data/s_axi_aresetn] [get_bd_pins CE/s_axi_aresetn] [get_bd_pins axis_sw/s_axi_aresetn] [get_bd_pins btn/s_axi_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst/s_axi_aresetn] [get_bd_pins rst_processing_system7_0_50M/peripheral_aresetn] [get_bd_pins sw/s_axi_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x41270000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs CE/S_AXI/Reg] SEG_CE_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41260000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs Axis_Data/S_AXI/Reg] SEG_Z_AXIS_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41220000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axis_sw/S_AXI/Reg] SEG_acl_sw_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs sw/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41230000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs btn/S_AXI/Reg] SEG_btn_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41210000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs rst/S_AXI/Reg] SEG_rst_Reg
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


