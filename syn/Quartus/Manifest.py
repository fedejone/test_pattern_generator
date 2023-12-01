target = "altera"
action = "synthesis"
language = "SystemVerilog"

syn_family = "Cyclone IV E"
syn_device = "EP4CE115"
syn_grade = "C7"
syn_package = "F29"
syn_top = "test_pattern_generator_ciris_top"
syn_project = "test_pattern_generator_ciris_top"
syn_tool = "quartus-modified"
syn_properties = [
	{"name": "NUM_PARALLEL_PROCESSORS", "value": "ALL"},
    {"name": "VHDL_INPUT_VERSION", "value": "VHDL_2008"},
    {"name": "VERILOG_INPUT_VERSION", "value": "SYSTEMVERILOG_2005"},
    {"name": "optimization_technique", "value": "BALANCED"}
]


##quartus_preflow='tcl/quartus_preflow.tcl'
quartus_postmodule ="module.tcl"
##quartus_postflow = 'tcl/quartus_postflow.tcl'

modules = {
 "local" : [ "../../rtl", #rtl
 ]
}
