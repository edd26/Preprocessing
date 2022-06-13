#!/bin/bash

# DESCRIPTION:
# Runs brain estraction tool for the selected file under DATA_PATH.
# Script written for MSC data which hadn multiple sessions.
# The F_VAL is the threshold for brain extraction

# Input arguments:


# TODO:
# - add parameter to have 4D data processed, not only a single frame (default)
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
set -e

source naming_functions.sh

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments

# SUBJECT_ID=$1
SUBEJCTS_MIN=$1
SUBEJCTS_MAX=$2
TOTAL_SESSIONS=$3
TOTAL_RUNS=$4

F_VAL=$5

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# CONSTANTS
BET_PATH="/usr/local/fsl/bin/bet"
EXTENSION=".nii"

PWD=`pwd`

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Run the analysis

echo
echo "===-===-===-"
echo "Running BET"
echo
# Subjects
for i in `seq -f "%02g" $SUBEJCTS_MIN $SUBEJCTS_MAX`; do

    # Sessions
    for f in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do

        DATA_PATH=$PWD/"0${i}"/"ses-func${f}"/"func"

        for TASK in "glasslexical" "memoryfaces" "memoryscenes" "memorywords" "motor"; do

            if [[ "${TASK}" == "motor" ]] || [[ "${TASK}" == "glasslexical" ]]; then
                # Runs
                for r in `seq -f "%02g" 1 ${TOTAL_RUNS}`; do
                    get_BET_done
                done # r
            else
                r=1
                get_BET_done
            fi # tasks

        done # TASK
    done # f
done # i

echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
echo "Finished processing subjects."
echo "Please inspect results."



