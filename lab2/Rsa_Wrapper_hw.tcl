# TCL File Generated by Component Editor 15.0
# Sat Mar 25 18:17:39 CST 2023
# DO NOT MODIFY


# 
# Rsa_Wrapper "Rsa_Wrapper" v1.0
#  2023.03.25.18:17:39
# 
# 

# 
# request TCL package from ACDS 15.0
# 
package require -exact qsys 15.0


# 
# module Rsa_Wrapper
# 
set_module_property DESCRIPTION ""
set_module_property NAME Rsa_Wrapper
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME Rsa_Wrapper
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL Rsa256Wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file Rsa256Core.sv SYSTEM_VERILOG PATH src/Rsa256Core.sv
add_fileset_file Rsa256Wrapper.sv SYSTEM_VERILOG PATH src/Rsa256Wrapper.sv TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point avalon_master_0
# 
add_interface avalon_master_0 avalon start
set_interface_property avalon_master_0 addressUnits SYMBOLS
set_interface_property avalon_master_0 associatedClock clock_sink
set_interface_property avalon_master_0 associatedReset reset_sink
set_interface_property avalon_master_0 bitsPerSymbol 8
set_interface_property avalon_master_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_master_0 burstcountUnits WORDS
set_interface_property avalon_master_0 doStreamReads false
set_interface_property avalon_master_0 doStreamWrites false
set_interface_property avalon_master_0 holdTime 0
set_interface_property avalon_master_0 linewrapBursts false
set_interface_property avalon_master_0 maximumPendingReadTransactions 0
set_interface_property avalon_master_0 maximumPendingWriteTransactions 0
set_interface_property avalon_master_0 readLatency 0
set_interface_property avalon_master_0 readWaitTime 1
set_interface_property avalon_master_0 setupTime 0
set_interface_property avalon_master_0 timingUnits Cycles
set_interface_property avalon_master_0 writeWaitTime 0
set_interface_property avalon_master_0 ENABLED true
set_interface_property avalon_master_0 EXPORT_OF ""
set_interface_property avalon_master_0 PORT_NAME_MAP ""
set_interface_property avalon_master_0 CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_master_0 avm_address address Output 5
add_interface_port avalon_master_0 avm_read read Output 1
add_interface_port avalon_master_0 avm_readdata readdata Input 32
add_interface_port avalon_master_0 avm_write write Output 1
add_interface_port avalon_master_0 avm_writedata writedata Output 32
add_interface_port avalon_master_0 avm_waitrequest waitrequest Input 1


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink CMSIS_SVD_VARIABLES ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink avm_clk clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink avm_rst reset Input 1

