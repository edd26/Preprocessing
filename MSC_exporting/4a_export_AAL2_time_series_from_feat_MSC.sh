#!/bin/bash

# DESCRIPTION:
# Scripts extracts regions signal based on AAL2 atlas brain parcellation.
#
# This is done by masking the brain with a collection of masks (each
# corresponds to a brain region from AAL2 atlas) and then computing average
# voxel intensity for the masked brain. It is assumed that the FEAT output
# folder have the following files in its structure:
# - "ICA_AROMA/denoised_func_data_nonaggr"
# - "reg/example_func2standard.mat"
#
# Input arguments:
# - SUBEJCTS_MIN: starting subject index
# - SUBEJCTS_MAX: ending subject index
# - TOTAL_SESSIONS: total_sessions to include in the computations

# TODO:
# - add project home dir as an input
# - parallelize computations
# - this should be split into functions, with base being a function doing the steps
#    and iteration should be done as a wrapper

set -e

source naming_functions

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
SUBEJCTS_MIN=$1
SUBEJCTS_MAX=$2
TOTAL_SESSIONS=$3
TOTAL_RUNS=$4

TASK=$5
# e.g. motor

MASKS_FOLDER=$6
# e.g. MASKS_FOLDER="./AAl2_masks"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
echo "pwd: " `pwd`
echo "Masks folder: " $MASKS_FOLDER

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
# Create reference template file
echo `fslmaths /usr/local/fsl/data/standard/MNI152_T1_2mm_brain standard`
MNI_BRAIN_TEMPLATE=standard

MNI_BRAIN_MASK=/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask

# ===-
# Create reference atlas check
if [[ -e $MNI_BRAIN_TEMPLATE".nii.gz" ]]; then
    echo "Refernce atlas is correct."
else
    echo "Reference atlas is missing!"
    # echo "Make sure that there exists ./AAl2_masks at the location where script is run!"
    exit
fi


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Run the analysis

echo
echo "===-===-===-"
echo "Running main analysis"
# Subjects
for i in `seq -f "%02g" $SUBEJCTS_MIN $SUBEJCTS_MAX`; do
    
    # Sessions
    for f in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do
        
        # Runs
        for r in `seq -f "%02g" 1 $TOTAL_RUNS`; do
            PWD_FOLDER=`pwd`
            
            DATA_PATH="0${i}"/"ses-func${f}"/"func"
            # SUBJECT="sub-MSC${i}_ses-func${f}_task-${TASK}_run-${r}_bold_brain";
            SUBJECT="$(get_file_name i f TASK r )";
            echo "Currently working on SUBJECT:"
            echo $SUBJECT
            echo
            
            FEAT_FOLDER=$PWD_FOLDER/$DATA_PATH/$SUBJECT".feat"
            
            TIME_SERIES_FOLDER=$FEAT_FOLDER/"time_series_export"
            MASKED_BRAIN_FILE=$FEAT_FOLDER/"filtered_func_in_MNI_masked.nii.gz"
            
            
            # ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
            # Set up export folder
            echo "===-===-===-"
            echo "Setting up time series export folder"
            echo "at "$TIME_SERIES_FOLDER
            echo
            
            if [[ -e $TIME_SERIES_FOLDER ]]; then
                echo "Folder for time series exists."
                # ls $TIME_SERIES_FOLDER
            else
                echo "Folder for time series does not exist."
                # echo "Creating one at ${TIME_SERIES_FOLDER}"
                mkdir "$TIME_SERIES_FOLDER"
            fi
            
            echo ""
            echo "===-===-"
            echo "Part 4- extract regions signal based on AAL2 atlas brain parcellation"
            for MASK_FILE in $(ls $MASKS_FOLDER); do
                OUTPUT_TEXT_FILE=$TIME_SERIES_FOLDER/$(echo $MASK_FILE | sed 's:\.nii\.gz:\_signal.txt:g')
                
                echo ""
                echo "===-"
                echo "Processing mask:" $MASK_FILE
                
                if [[ -e $OUTPUT_TEXT_FILE ]]; then
                    echo $OUTPUT_TEXT_FILE  " exists."
                else
                    fslmeants -i $MASKED_BRAIN_FILE -o $OUTPUT_TEXT_FILE -m $MASKS_FOLDER/$MASK_FILE
                fi
            done
            
            echo "===-===-"
            echo
        done # r
    done # f
done # i
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
echo "Finished processing subjects."
echo "Please inspect results."
