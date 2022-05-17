#!/bin/bash

set -e

# DESCRIPTION:
# Runs brain estraction tool for the selected file under DATA_PATH.
# Script written for MSC data which hadn multiple sessions.
# The F_VAL is the threshold for brain extraction

# Input arguments:


# TODO:
# - add parameter to have 4D data processed, not only a single frame (default)


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments

DATA_PATH=$1

TOTAL_SESSIONS=$2

F_VAL=$3

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# CONSTANTS
BET_PATH="/usr/local/fsl/bin/bet"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Run the analysis

EXTENSION=".nii"

echo
echo "===-===-===-"
echo "Running BET"
echo
for i in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do

    for TASK in "glasslexical_run-01" "glasslexical_run-02" "memoryfaces" "memoryscenes" "memorywords"; do

        IN_FILE=$DATA_PATH/"sub-MSC01_ses-func""$i""_task-"$TASK"_bold"
        FULL_IN_FILE=$IN_FILE$EXTENSION
                            # sub-MSC01_ses-func01_task-glasslexical_run-01_bold
        OUT_FILE="${IN_FILE}_brain.nii.gz"

        if [[ -e $FULL_IN_FILE ]]; then
            echo "Input file exists!"
        else
            echo "Input file does not exists!"
        fi
        echo $FULL_IN_FILE

        if [[ -e $OUT_FILE ]]; then
            echo $OUT_FILE
            echo " file exists. Skipping..."
        else
            echo "Running BET"
            echo $BET_PATH $IN_FILE $OUT_FILE -F -f $F_VAL -g 0

            $BET_PATH $IN_FILE $OUT_FILE -F -f $F_VAL -g 0
        fi
        echo
    done

    #
    #

done
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
echo "Finished processing subjects."
echo "Please inspect results."



