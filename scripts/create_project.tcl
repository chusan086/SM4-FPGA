# create_project.tcl - SM4 block cipher for RK-ZYNQ7100-F (XC7Z100)
# Vivado 2023.1

create_project -force sm4_prj ./sm4_prj -part xc7z100ffg900-2
set_property target_language Verilog [current_project]

# Add RTL sources
add_files -norecurse [glob ../rtl/*.sv]

# Add simulation sources
add_files -norecurse -fileset sim_1 [glob ../sim/*.sv]

# Add constraints
add_files -norecurse -fileset constrs_1 ../constr/sm4_prj1.xdc

# Add IP cores
add_files -norecurse [glob ../ip/*/*.xci]

# Add Block Design
read_bd ../bd/design_1/design_1.bd

set_property top sm4_axi_top [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "SM4 project created successfully."
