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

        echo
        # Run
        for r in `seq -f "%02g" 1 2`; do

            # SESSION_NAME=
                             # 001_sub-MSC01  _ses-func01  _task-motor_run-01  _bold_brain.feat
            WORKING_DIRECTORY="./001_sub-MSC${i}_ses-func${f}_task-motor_run-${r}_bold_brain.feat"

            # SESSION_NAME="MSC01_ses1_motor_run01"
            SESSION_NAME="MSC${i}_ses${f}_motor_run${r}"

            ./symmetric_voxels_signal_export.sh ${WORKING_DIRECTORY} ${SESSION_NAME} ${MASKS_PATH} ${BRAIN_REGION}
        done # r
    done # f
done # i
