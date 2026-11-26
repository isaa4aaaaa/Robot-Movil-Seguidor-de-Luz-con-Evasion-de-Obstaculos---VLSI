create_clock -name clk_50 -period 20.000 [get_ports {clk}]
derive_clock_uncertainty
set_false_path -from [get_ports {key0_n}] -to [get_registers {*key_1}]
set_false_path -from [get_ports {sw[*]}] -to [get_registers {*sw_1[*]}]
# El puente no tiene reloj receptor; las salidas se verifican en banco.
set_false_path -to [get_ports {ain1 ain2 bin1 bin2 stby pwm_a pwm_b}]
