echo "********** CS552 Reading files begin ********************"
set my_verilog_files [list alu_control.v alu.v bit_2shift.v bit_4shift.v bit_8shift.v bit_shift.v brchcnd.v cache_controller.v cache.v cla_1b.v cla_4b.v cla_16b.v control.v decode.v dff.v DMWB_latch.v EXDM_latch.v execute.v fetch.v final_memory.syn.v forwarding.v four_bank_mem.v IDEX_latch.v IFID_latch.v mem_system.v memc.syn.v memory.v memory2c_align.syn.v memory2c.syn.v memv.syn.v nand2.v nand3.v nor2.v nor3.v not1.v proc.v regFile_bypass.v regFile.v register.v shifter.v stall_mech.v stallmem.syn.v wb.v xor2.v xor3.v  ]
set my_toplevel proc
define_design_lib WORK -path ./WORK
analyze -f verilog $my_verilog_files
elaborate $my_toplevel -architecture verilog
echo "********** CS552 Reading files end ********************"
current_design proc
#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
set my_clock_pin clk

#/* Target frequency in MHz for optimization       */
set my_clk_freq_MHz 1000

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0.1

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0.1


#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
set verilogout_show_unconnected_pins "true"


# analyze -f verilog $my_verilog_files
# elaborate $my_toplevel -architecture verilog
# current_design $my_toplevel

report_hierarchy 
link
uniquify

set my_period [expr 1000 / $my_clk_freq_MHz]

set find_clock [ find port [list $my_clock_pin] ]
if {  $find_clock != [list] } {
   set clk_name $my_clock_pin
   create_clock -period $my_period $clk_name
} else {
   set clk_name vclk
   create_clock -period $my_period -name $clk_name
} 

set_driving_cell  -lib_cell INVX1  [all_inputs]
set_input_delay $my_input_delay_ns -clock $clk_name [remove_from_collection [all_inputs] $my_clock_pin]
set_output_delay $my_output_delay_ns -clock $clk_name [all_outputs]

compile -map_effort medium  -area_effort low

check_design -summary
report_constraint -all_violators

set filename [format "%s%s"  $my_toplevel ".syn.v"]
write -hierarchy -f verilog $my_toplevel -output synth/$filename
set filename [format "%s%s"  $my_toplevel ".ddc"]
write -hierarchy -format ddc -output synth/$filename

report_reference > synth/reference_report.txt
report_area > synth/area_report.txt
report_cell > synth/cell_report.txt
report_timing -max_paths 20 > synth/timing_report.txt
report_power > synth/power_report.txt

quit

