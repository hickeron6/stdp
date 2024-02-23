#!/usr/bin/bash

TOP_ENTITY="Stdp_tb"

xelab $TOP_ENTITY

xsim -t commands.tcl $TOP_ENTITY

#python "../../stdp_vhdl/stdp/delta_weight_trans.py"
