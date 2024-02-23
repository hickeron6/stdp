#!/usr/bin/bash

root_dir=$(pwd)

#echo "Weight_ini and Spike_gen"
#cd ini_weight
#python ini_w.py
#python spike_gen.py
#cd $root_dir

echo "stdp_py gen"
cd stdp
python stdp_z_4.py
cd $root_dir


