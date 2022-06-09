#!/bin/bash
 
# DESCRIPTION:
# Script for iterating over subjects, sessions and runs. This can only
# be run once the feat analysis is done.
# 
# ASSUMPTIONS:
# - the FEAT results are placed in the original MSC nii.gz file location
# - the name of FEAT result is the same as original file name
# - atm, it runs only at the motor task
# - the script have to be run from the root func directory in MSC data file structure
# 
# TODO add limiters for subjects and sessions

set -e

# MASKS_PATH="../../../david_data/AAl2_masks"
MASKS_PATH=$1

# BRAIN_REGION="Supp_Motor_Area"
BRAIN_REGION=$2

TASK=$3
# e.g."memorywords", "motor"

# Subjects
for i in `seq -f "%02g" 1 1`; do

    # Session
    for f in `seq -f "%02g" 1 3`; do

        # Run
        for r in `seq -f "%02g" 1 2`; do
            WORKING_DIRECTORY="./0${i}/ses-func${f}/func/sub-MSC${i}_ses-func${f}_task-${TASK}_run-${r}_bold_brain.feat"
            SESSION_NAME="MSC${i}_ses${f}_motor_run${r}"

            echo "Working in: " $WORKING_DIRECTORY $SESSION_NAME

            # Side
            for s in "L" "R"; do
                FINAL_BRAIN_REGION="${BRAIN_REGION}_${s}"
                echo "With region: " $FINAL_BRAIN_REGION
                
                ./../brain-scripting/voxel_export_templates/symmetric_voxels_signal_export.sh ${WORKING_DIRECTORY} ${SESSION_NAME} ${MASKS_PATH} ${FINAL_BRAIN_REGION}
            done # s
        done # r
    done # f
    
    echo 'Next subject, if there is one on the list...'
done # i
