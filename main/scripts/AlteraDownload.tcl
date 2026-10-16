# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
    if {[string compare $quartus(project) "logisimTopLevelShell"]} {
        puts "Project logisimTopLevelShell is not open"
        set make_assignments 0
    }
} else {
    # Only open if not already open
    if {[project_exists logisimTopLevelShell]} {
        project_open -revision logisimTopLevelShell logisimTopLevelShell
    } else {
        project_new -revision logisimTopLevelShell logisimTopLevelShell
    }
    set need_to_close_project 1
}
# Make assignments
if {$make_assignments} {

   set_global_assignment -name FAMILY "Cyclone V"
   set_global_assignment -name DEVICE 5CGXFC5C6F27C7
   set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
   set_global_assignment -name DEVICE_FILTER_PIN_COUNT 672
   set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
   set_global_assignment -name FMAX_REQUIREMENT "50 MHz "
   set_global_assignment -name RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
   set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"

    # Include all entities and gates


    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/toplevel/logisimTopLevelShell_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/gates/AND_GATE_3_INPUTS_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/gates/AND_GATE_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/gates/OR_GATE_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/main_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/bloco_ctr_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/bloco_op_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/log_comb_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/base/logisimTickGenerator_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/base/LogisimClockComponent_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/base/synthesizedClockGenerator_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/memory/REGISTER_FLIP_FLOP_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/arith/Adder_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/arith/Comparator_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/plexers/Demultiplexer_bus_2_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/plexers/Multiplexer_bus_2_entity.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/toplevel/logisimTopLevelShell_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/gates/AND_GATE_3_INPUTS_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/gates/AND_GATE_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/gates/OR_GATE_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/main_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/bloco_ctr_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/bloco_op_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/circuit/log_comb_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/base/logisimTickGenerator_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/base/LogisimClockComponent_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/base/synthesizedClockGenerator_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/memory/REGISTER_FLIP_FLOP_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/arith/Comparator_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/arith/Adder_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/plexers/Demultiplexer_bus_2_behavior.vhd"
    set_global_assignment -name VHDL_FILE "/home/murilo/logisim_evolution_workspace/trabalho_phi/main/vhdl/plexers/Multiplexer_bus_2_behavior.vhd"

    # Map fpga_clk and ionets to fpga pins
    set_location_assignment PIN_R20 -to fpgaGlobalClock
    # Commit assignments
    export_assignments

    # Close project
    if {$need_to_close_project} {
        project_close
    }
}

