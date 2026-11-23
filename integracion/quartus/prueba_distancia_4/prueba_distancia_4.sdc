create_clock -name clk_50 -period 20.000 [get_ports {clk}]
derive_clock_uncertainty
# Solo entradas asincronas hasta el primer registro sincronizador.
set_false_path -from [get_ports {echo[*]}] -to [get_registers {*echo_1}]
set_false_path -from [get_ports {selector[*]}] -to [get_registers {*selector_1[*]}]
set_false_path -to [get_ports {trig[*] hex0[*] hex1[*] hex2[*]}]
