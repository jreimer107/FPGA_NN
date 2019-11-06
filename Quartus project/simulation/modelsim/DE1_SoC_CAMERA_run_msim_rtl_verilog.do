transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/sdram_pll.vo}
vlib sdram_pll
vmap sdram_pll sdram_pll
vlog -vlog01compat -work sdram_pll +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/sdram_pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/VGA_Controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/SEG7_LUT.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/Reset_Delay.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/RAW2RGB.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/I2C_Controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/I2C_CCD_Config.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/CCD_Capture.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/SEG7_LUT_6.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/Line_Buffer1.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/Sdram_Control {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/Sdram_Control/Sdram_RD_FIFO.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/Sdram_Control {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/Sdram_Control/Sdram_WR_FIFO.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/de1_soc_camera.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/Sdram_Control {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/Sdram_Control/Sdram_Control.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/Sdram_Control {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/Sdram_Control/sdr_data_path.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/Sdram_Control {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/Sdram_Control/control_interface.v}
vlog -vlog01compat -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/Sdram_Control {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/Sdram_Control/command.v}
vlog -vlog01compat -work sdram_pll +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v/sdram_pll {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/sdram_pll/sdram_pll_0002.v}
vlog -sv -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/v {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/v/Shift_Register.sv}

vlog -sv -work work +incdir+C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus\ project/.. {C:/Users/ECE_STUDENT/Documents/FPGA_NN/Quartus project/../BMem_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiv_hssi_ver -L cycloneiv_pcie_hip_ver -L cycloneiv_ver -L rtl_work -L work -L sdram_pll -voptargs="+acc"  BMEM_tb

add wave *
view structure
view signals
run -all
