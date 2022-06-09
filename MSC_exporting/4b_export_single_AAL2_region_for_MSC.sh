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

source naming_functions.sh

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
SUBEJCTS_MIN=$1
SUBEJCTS_MAX=$2
TOTAL_SESSIONS=$3
TOTAL_RUNS=$4

TASK=$5
# e.g.memorywords, motor

MASKS_FOLDER=$6
# e.g. MASKS_FOLDER="./AAl2_masks"
# MASKS_FOLDER="../../../david_data/AAl2_masks"

BRAIN_REGION=$7
# BRAIN_REGION="Supp_Motor_Area"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
echo "pwd: " `pwd`
echo "Masks folder: " $MASKS_FOLDER

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Subjects
for i in `seq -f "%02g" $SUBEJCTS_MIN $SUBEJCTS_MAX`; do
    
    # Sessions
    for f in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do
        
        # Runs
        for r in `seq -f "%02g" 1 $TOTAL_RUNS`; do
            PWD_FOLDER=`pwd`
            DATA_PATH="0${i}"/"ses-func${f}"/"func"
            
            # SUBJECT="sub-MSC${i}_ses-func${f}_task-${TASK}_run-${r}_bold_brain"
            get_file_name $i $f $TASK $r 1
            SUBJECT=$FINAL_NAME
            echo "Currently working on SUBJECT:"
            echo $SUBJECT
            echo
            
            # SESSION_NAME="MSC${i}_ses${f}_motor_run${r}"
            get_session_name $i $f $TASK $r
            SESSION_NAME=SESSION_FINAL_NAME
            
            FEAT_FOLDER=$PWD_FOLDER/$DATA_PATH/$SUBJECT".feat"
            
            echo "Folder and session: " $FEAT_FOLDER $SESSION_NAME
            
            # Side
            for s in "L" "R"; do
                FINAL_BRAIN_REGION="${BRAIN_REGION}_${s}"
                echo "With region: " $FINAL_BRAIN_REGION
                
                ./../brain-scripting/voxel_export_templates/symmetric_voxels_signal_export.sh ${FEAT_FOLDER} ${SESSION_NAME} ${MASKS_FOLDER} ${FINAL_BRAIN_REGION}
            done # s
        done # r
    done # f
    
    echo 'Next subject, if there is one on the list...'
done # i
