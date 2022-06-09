#!/bin/bash

set -e

source naming_functions.sh

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
SUBEJCTS_MIN=$1
SUBEJCTS_MAX=$2
TOTAL_SESSIONS=$3
TOTAL_RUNS=$4

# TASK=$5
# # e.g. motor

# MASKS_FOLDER=$6
# # e.g. MASKS_FOLDER="./AAl2_masks"

BRAIN_REGION=$5

# Subjects
# Subjects
for i in `seq -f "%02g" $SUBEJCTS_MIN $SUBEJCTS_MAX`; do
    
    # Sessions
    for f in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do
        
        # Runs
        for r in `seq -f "%02g" 1 $TOTAL_RUNS`; do
            
            # Side
            for s in "R" "L"; do
                # SRC_FOLDER="./0${i}/0${i}_sub-MSC${i}_ses-func${f}_task-motor_run-${r}_bold_brain.feat"
                SRC_FOLDER="./0${i}/ses-func${f}/func/sub-MSC${i}_ses-func${f}_task-motor_run-${r}_bold_brain.feat"
                SUBFOLDER="MSC${i}_ses${f}_motor_run${r}_${BRAIN_REGION}_${s}_voxel_export"
                TARGET_DIR="${HOME}/Programming/Julia/SchiTopology/data/exp_raw/voxel_data/whole_brain/"
                
                echo "Copying folder: $SRC_FOLDER/$SUBFOLDER"
                
                # mkdir $TARGET_DIR
                cp -r "$SRC_FOLDER/$SUBFOLDER" $TARGET_DIR
                
            done # s
        done # r
    done # f
done # i

