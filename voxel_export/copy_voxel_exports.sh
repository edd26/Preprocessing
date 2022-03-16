#!/bin/bash

set -e

BRAIN_REGION=$1

# Subjects
for i in `seq -f "%02g" 1 1`; do

    # Session
    for f in `seq -f "%02g" 1 3`; do

        # Run
        for r in `seq -f "%02g" 1 2`; do

            # Side
            for s in "R" "L"; do
                SRC_FOLDER="./0${i}/0${i}_sub-MSC${i}_ses-func${f}_task-motor_run-${r}_bold_brain.feat"
                SUBFOLDER="MSC${i}_ses${f}_motor_run${r}_${BRAIN_REGION}_${s}_voxel_export"
                TARGET_DIR="${HOME}/Programming/Julia/SchiTopology/data/exp_raw/voxel_data/whole_brain/"


                echo "Copying folder: $SRC_FOLDER/$SUBFOLDER"

                # mkdir $TARGET_DIR
                cp -r "$SRC_FOLDER/$SUBFOLDER" $TARGET_DIR

            done # s
        done # r
    done # f
done # i

