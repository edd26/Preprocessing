#!/bin/bash

set -e

# MASKS_PATH="../../../david_data/AAl2_masks"
MASKS_PATH=$1

# BRAIN_REGION="Supp_Motor_Area"
BRAIN_REGION=$2


# Subjects
for i in `seq -f "%02g" 1 1`; do

    # Session
    for f in `seq -f "%02g" 1 3`; do


        # Run
        for r in `seq -f "%02g" 1 2`; do
            WORKING_DIRECTORY="./0${i}/001_sub-MSC${i}_ses-func${f}_task-motor_run-${r}_bold_brain.feat"
            SESSION_NAME="MSC${i}_ses${f}_motor_run${r}"

            echo "Working in: " $WORKING_DIRECTORY

            # Side
            for s in "L" "R"; do
                FINAL_BRAIN_REGION="${BRAIN_REGION}_${s}"
                echo "With region: " $FINAL_BRAIN_REGION

                ./symmetric_voxels_signal_export.sh ${WORKING_DIRECTORY} ${SESSION_NAME} ${MASKS_PATH} ${FINAL_BRAIN_REGION}
            done # s
        done # r
    done # f

    echo "Next i if there is one..."
done # i
