derive_clock_uncertainty
create_clock -period 200MHz -name {clk_i} [get_ports {clk_i}]
set_false_path -from [get_clocks {clk}] -to [get_ports {led}]
set_false_path -from [get_registers {mux_test_pattern_generator_ciris:uut_mux_test_pattern_generator_ciris|width_o[*]}] -to [get_registers {test_pattern_generator_ciris:uut_test_pattern_generator_ciris|data_reg_image[*]}]
set_false_path -from [get_registers {mux_test_pattern_generator_ciris:uut_mux_test_pattern_generator_ciris|height_o[*]}] -to [get_registers {test_pattern_generator_ciris:uut_test_pattern_generator_ciris|data_reg_image[*]}]