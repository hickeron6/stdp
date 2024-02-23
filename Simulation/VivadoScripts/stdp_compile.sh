#!/usr/bin/bash


TOP_ENTITY="Stdp_tb"

# vhdl_dir="../all_comp"

# xvhdl $vhdl_dir"/encoder.vhd"
# xvhdl $vhdl_dir"/queue.vhd"
# xvhdl $vhdl_dir"/weight_trans.vhd"

# xvhdl $vhdl_dir"/stdp.vhd"

# xvhdl $vhdl_dir"/stdp_infile_tb.vhd"



xvhdl "../../stdp_vhdl/encoder/encoder.vhd"
xvhdl "../../stdp_vhdl/queue/queue.vhd"
xvhdl "../../stdp_vhdl/weight_trans/weight_trans.vhd"

xvhdl "../../stdp_vhdl/stdp/stdp.vhd"

xvhdl "../../stdp_vhdl/stdp/stdp_infile_tb.vhd"
