create_clock -name clk_50 -period 20.000 [get_ports {clk}]
derive_clock_uncertainty
set_false_path -from [get_ports {key0_n}] -to [get_registers {*key0_1}]
set_false_path -from [get_ports {key1_n}] -to [get_registers {*key1_1}]
set_false_path -from [get_ports {ldr_d0[*]}] -to [get_registers {*etapa_1[*]}]
set_false_path -from [get_ports {echo[*]}] -to [get_registers {*echo_1}]
set_false_path -to [get_ports {trig[*] ain1 ain2 bin1 bin2 stby pwm_a pwm_b leds[*]}]
