#!/bin/bash

set -e

# DESCRIPTION:

# Input arguments:


# TODO:


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
# eg. NAME_TEMPLATE="_FEAT_2022-01-05"

DATA_PATH=$1

TOTAL_SESSIONS=$2

F_VAL=$3

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# CONSTANTS
BET_PATH="/usr/local/fsl/bin/bet"


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-


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
            echo $FULL_IN_FILE
        else
            echo "Input file does not exists!"
            echo $FULL_IN_FILE
        fi

        if [[ -e $OUT_FILE ]]; then
            echo $OUT_FILE
            echo " file exists. Skipping..."
        else
            echo "Running BET"
            echo $BET_PATH $IN_FILE $OUT_FILE -f $F_VAL -g 0

            $BET_PATH $IN_FILE $OUT_FILE -f $F_VAL -g 0
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



