set_global_assignment -entity "pll64" -library "lib_pll64" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll64" -library "lib_pll64" -name IP_TOOL_VERSION "24.1"
set_global_assignment -entity "pll64" -library "lib_pll64" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll64" -name SPD_FILE [file join $::quartus(sip_path) "pll64.spd"]

set_global_assignment -library "lib_pll64" -name MISC_FILE [file join $::quartus(sip_path) "pll64_sim/pll64.vo"]
