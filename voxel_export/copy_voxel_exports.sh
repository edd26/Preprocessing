#!/bin/bash

set -e

# Subjects
for i in `seq -f "%01g" 1 1`; do

    # Session
    for f in `seq -f "%01g" 1 1`; do

        # Run
        for r in `seq -f "%01g" 1 2`; do

            # Side
            for s in "R" "L"; do
                SRC_FOLDER="00${i}_sub-MSC0${i}_ses-func0${f}_task-motor_run-0${r}_bold_brain.feat"
                SUBFOLDER="MSC0${i}_ses${f}_motor_run0${r}_Supp_Motor_Area_${s}_masked_voxel_export"
                TARGET_DIR="${HOME}/Programming/Julia/SchiTopology/data/exp_raw/voxel_data/whole_brain/"


                echo "Copying folder: $SRC_FOLDER/$SUBFOLDER"

                # mkdir $TARGET_DIR
                cp -r "$SRC_FOLDER/$SUBFOLDER" $TARGET_DIR

            done # s
        done # r
    done # f
done # i

