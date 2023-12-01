action = "simulation"
sim_tool = "modelsim"
sim_top = "tb_test_pattern_generator_ciris"

sim_post_cmd = "vsim -voptargs=+acc -do wave.do -i tb_test_pattern_generator_ciris"

modules = {
  "local" : [ "../../../tb/tb_test_pattern_generator_ciris" ],
}
