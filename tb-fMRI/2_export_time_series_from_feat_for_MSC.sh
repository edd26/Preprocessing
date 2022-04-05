#!/bin/bash

set -e

# DESCRIPTION:
# Scripts transforms FEAT processed BOLD fMRI data with the following steps:
# - FEAT smoothed data ->
# - AROMA denoising ->
# - transform into the MNI space ->
# - apply MNI brain mask ->
# - extract regions signal based on AAL2 atlas brain parcellation
#
# Last step is done by masking the brain with a collection of masks (each
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
# - AROMA_SCRIPT: path to the aroma scripts for preprocessing

# The output of the script is:
# - "processed.nii.gz"

# TODO:
# - add project home dir as an input
# - parallelize computations
# - this should be split into functions, with base being a function doing the steps
#    and iteration should be done as a wrapper


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
SUBEJCTS_MIN=$1
SUBEJCTS_MAX=$2
TOTAL_SESSIONS=$3
AROMA_PATH=$4
# e.g. ICA_AROMA


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Report pwd
echo "pwd: " `pwd`

PYTHON_PATH="/home/ed19aaf/.pyenv/versions/ica-aroma/bin"

# ===-
# Global variables set up
TOTAL_RUNS=2

MASKS_FOLDER="./AAl2_masks"
echo "Masks folder: " $MASKS_FOLDER

AROMA_SCRIPT=$AROMA_PATH/"ICA_AROMA.py"

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
for i in `seq -f "%02g" $SUBEJCTS_MIN $SUBEJCTS_MAX`; do
    for f in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do
        for r in `seq -f "%02g" 1 $TOTAL_RUNS`; do
            PWD_FOLDER=`pwd`

            # SUBJECT="$i$NAME_TEMPLATE";
            DATA_PATH="0${i}"/"ses-func${f}"/"func"
            SUBJECT="sub-MSC${i}_ses-func${f}_task-motor_run-${r}_bold_brain";
            FEAT_FOLDER=$PWD_FOLDER/$DATA_PATH/$SUBJECT".feat"

            AROMA_OUT=$FEAT_FOLDER/"ICA_AROMA"
            BOLD_IN_SCANNER=$FEAT_FOLDER/"ICA_AROMA/denoised_func_data_nonaggr"
            BOLD_IN_MNI=$FEAT_FOLDER/"filtered_func_in_MNI.nii.gz"
            TRASNSFORMATION_MATRIX=$FEAT_FOLDER/"reg/example_func2standard.mat"
            MASKED_BRAIN_FILE=$FEAT_FOLDER/"filtered_func_in_MNI_masked.nii.gz"
            TIME_SERIES_FOLDER=$FEAT_FOLDER/"time_series_export"

            echo "Currently working on SUBJECT:"
            echo $SUBJECT
            echo

            # ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
            # Set up export folder
            echo "===-===-===-"
            echo "Setting up time series export folder"
            echo "at "$TIME_SERIES_FOLDER
            echo


            if [[ -e $TIME_SERIES_FOLDER ]]; then
                echo "Folder for time series exists."
                ls $TIME_SERIES_FOLDER
            else
                echo "Folder for time series does not exist."
                echo "Creating one at ${TIME_SERIES_FOLDER}"
                mkdir "$TIME_SERIES_FOLDER"
            fi

            echo "Processing subject at:"
            echo $SUBJECT
            echo

            # ===-===-
            # - FEAT smoothed data ->


            # Part 1- AROMA denoising
            if [[ -d "$AROMA_OUT" ]]; then
                echo $AROMA_OUT" exists."
            else
                echo "Running AROMA..."

                ${PYTHON_PATH}/python ${AROMA_SCRIPT} -feat ${FEAT_FOLDER} -out ${AROMA_OUT}
            fi


            # Part 2 - transform into the MNI space
            if [[ -e $BOLD_IN_MNI ]]; then
                echo $BOLD_IN_MNI " exists."
            else
                # echo $BOLD_IN_MNI " does not exists"
                echo "Running flirt..."

                flirt -ref ${MNI_BRAIN_TEMPLATE} -in ${BOLD_IN_SCANNER} -out ${BOLD_IN_MNI} -applyxfm -init ${TRASNSFORMATION_MATRIX} -interp trilinear
            fi

            # Part 3- apply MNI brain mask
            if [[ -e $MASKED_BRAIN_FILE ]]; then
                echo $MASKED_BRAIN_FILE  " exists."
            else
                # echo $BOLD_IN_MNI " does not exists"
                echo "Running masking..."
                fslmaths ${BOLD_IN_MNI} -mul ${MNI_BRAIN_MASK} ${MASKED_BRAIN_FILE}
            fi

            # Part 4- extract regions signal based on AAL2 atlas brain parcellation
            echo ""
            echo "===-===-"
            echo "Running signal export:"
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
