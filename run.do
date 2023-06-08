vlib work
vlog functionalunit.sv -lint
vlog i2c_interface.sv -lint
vlog interface.sv -lint
#vlog i2ctb.sv -lint +acc
vlog memoryconroller.sv -lint
#vlog mc_tb.sv -lint

vlog top_module.sv -lint +acc



vsim work.topmodule
#add wave -r *

run -all