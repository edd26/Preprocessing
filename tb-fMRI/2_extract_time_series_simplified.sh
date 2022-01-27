#!/bin/bash

# DESCRIPTION:
# Scripts transforms FEAT processed BOLD fMRI data with the following steps:
# - FEAT smoothed data ->
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
# - NAME_TEMPLATE: FEAT folder name; it will be prefixed with a number
# - DATA_PATH: location of the FEAT folder
# - TOTAL_SUBEJCTS: total number of subjects for which the analysis will be run;
#
# The output of the script is:
# - "processed.nii.gz"


# TODO:
# - add project home dir as an input
# - parallelize computations
# - this should be split into functions, with base being a function doing the steps
#    and iteration should be done as a wrapper


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
NAME_TEMPLATE=$1
# eg. NAME_TEMPLATE="_FEAT_2022-01-05"

DATA_PATH=$2
# e.g. DATA_PATH="CRT0_processed"

TOTAL_SUBEJCTS=$3

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Report pwd
echo "pwd: " `pwd`

# ===-
# Global variables set up
MASKS_FOLDER="./AAl2_masks"
echo "Masks folder: " $MASKS_FOLDER

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
# Create reference template file
MNI_BRAIN_TEMPLATE=standard
echo `fslmaths /usr/local/fsl/data/standard/MNI152_T1_2mm_brain standard`

MNI_BRAIN_MASK=standard_mask
echo `fslmaths /usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask standard_mask`

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
for i in `seq -f "%03g" 1 $TOTAL_SUBEJCTS`; do
# - FEAT smoothed data ->
    # Part 1- running filtr
    SUBJECT="$i$NAME_TEMPLATE";
    TIME_SERIES_FOLDER=./$DATA_PATH/$SUBJECT/"time_series_export"
    SRC_FILE=./$DATA_PATH/$SUBJECT/"ICA_AROMA/denoised_func_data_nonaggr"
    TRASNSFORMATION_MATRIX=./$DATA_PATH/$SUBJECT/"reg/example_func2standard.mat"
    BOLD_IN_MNI=./$DATA_PATH/$SUBJECT/"filtered_func_in_MNI.nii.gz"
    MASKED_BRAIN_FILE=./$DATA_PATH/$SUBJECT/"filtered_func_in_MNI_masked.nii.gz"

    echo "SUBJECT:" $SUBJECT

    # ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
    # Set up export folder
    echo
    echo "===-===-===-"
    echo "Setting up export folder"
    echo "at "$TIME_SERIES_FOLDER


    if [[ -e $TIME_SERIES_FOLDER ]]; then
        echo "Folder exists."
        ls $TIME_SERIES_FOLDER
    else
        echo "Folder does not exist!"
        echo "Creating."
        mkdir $TIME_SERIES_FOLDER
    fi

    echo "Processing subject at:"
    echo $SRC_FILE
    echo


    # Part 1 - transform into the MNI space
    if [[ -e $BOLD_IN_MNI ]]; then
        echo $BOLD_IN_MNI " exists."
    else
        # echo $BOLD_IN_MNI " does not exists"
        echo "Running flirt..."

        flirt -ref ${MNI_BRAIN_TEMPLATE} -in ${SRC_FILE} -out ${BOLD_IN_MNI} -applyxfm -init ${TRASNSFORMATION_MATRIX} -interp trilinear
    fi

    # Part 2- apply MNI brain mask
    if [[ -e $MASKED_BRAIN_FILE ]]; then
        echo $MASKED_BRAIN_FILE  " exists."
    else
        # echo $BOLD_IN_MNI " does not exists"
        echo "Running masking..."
        fslmaths ${BOLD_IN_MNI} ${MNI_BRAIN_MASK} ${MASKED_BRAIN_FILE}
    fi

    # Part 3- extract regions signal based on AAL2 atlas brain parcellation
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
            fslmeants -i $MASKED_BRAIN_FILE-o $OUTPUT_TEXT_FILE -m $MASKS_FOLDER/$MASK_FILE
        fi
    done
    echo "===-===-"
    echo
done
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
echo "Finished processing subjects."
echo "Please inspect results."
