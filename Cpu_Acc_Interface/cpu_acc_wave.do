onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cpu_tb/PC
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_IFID/next_PC
add wave -noupdate -radix hexadecimal /cpu_tb/Inst
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/halt
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/dmem_data_from
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/dmem_ren
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/dmem_wren
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/dmem_addr
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/dmem_data_to
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/databus
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/bus_wr
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ccd_done
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ccd_en
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/accel_done
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/accel_en
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_reg1_data
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_reg2_data
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_EX/iForward
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_EX/aluin1
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_EX/aluin2
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_imm
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_dest
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_src1
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_src2
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_alutoreg
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_memtoreg
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_bustoreg
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_memread
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_memwrite
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_buswrite
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_opcode
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/ex_AluUseImm
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/nvz
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/forward
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_memread
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_memwrite
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_buswrite
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_alu_in
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_alu_src2
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_alutoreg
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_memtoreg
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/mem_bustoreg
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/wb_en
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/wb_dest
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/wb_data
add wave -noupdate -radix hexadecimal -childformat {{{/cpu_tb/DUT/CPU/U_IFID/registers[15]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[14]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[13]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[12]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[11]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[10]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[9]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[8]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[7]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[6]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[5]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[4]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[3]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[2]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[1]} -radix hexadecimal} {{/cpu_tb/DUT/CPU/U_IFID/registers[0]} -radix hexadecimal}} -expand -subitemconfig {{/cpu_tb/DUT/CPU/U_IFID/registers[15]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[14]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[13]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[12]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[11]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[10]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[9]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[8]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[7]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[6]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[5]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[4]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[3]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[2]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[1]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/CPU/U_IFID/registers[0]} {-height 15 -radix hexadecimal}} /cpu_tb/DUT/CPU/U_IFID/registers
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_IFID/branch
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_IFID/conditionResult
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/clk
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/reset
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/DRAMdata
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/data_bus
add wave -noupdate -radix hexadecimal -childformat {{{/cpu_tb/DUT/Acc0/BRAM_data[15]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[14]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[13]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[12]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[11]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[10]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[9]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[8]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[7]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[6]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[5]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[4]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[3]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[2]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[1]} -radix hexadecimal} {{/cpu_tb/DUT/Acc0/BRAM_data[0]} -radix hexadecimal}} -subitemconfig {{/cpu_tb/DUT/Acc0/BRAM_data[15]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[14]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[13]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[12]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[11]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[10]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[9]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[8]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[7]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[6]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[5]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[4]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[3]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[2]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[1]} {-height 15 -radix hexadecimal} {/cpu_tb/DUT/Acc0/BRAM_data[0]} {-height 15 -radix hexadecimal}} /cpu_tb/DUT/Acc0/BRAM_data
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/busrdwr
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/CPUEnable
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/DVAL
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/BRAM_Addr_In
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/output_neuron
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/out_addr_current
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/Rd_BRAM_current
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/Wr_BRAM_current
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/SRAM_RdReq
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/cpu_neuron_done
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/Weight_data_current
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/neuron_done
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/PE_enable
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/add_done
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/accum_sum
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/Acc0/partial_sum
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/address_a
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/address_b
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/clock
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/data_a
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/data_b
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/rden_a
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/rden_b
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/wren_a
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/wren_b
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/q_a
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/q_b
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/sub_wire0
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/DMEM/sub_wire1
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/CPU/U_EX/oAluOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7396 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 297
configure wave -valuecolwidth 398
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {6020 ps} {8215 ps}
