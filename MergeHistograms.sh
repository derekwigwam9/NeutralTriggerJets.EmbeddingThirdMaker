#!/bin/bash
# 'MergeHistograms.sh'
#
# Use this to merge some histograms.

#for i in 1 2 3 4
#do

root -b <<EOF
.x hadd_files.C("pt11.check.list","output/merged/pt11.thirdmaker.root")
EOF

#done
