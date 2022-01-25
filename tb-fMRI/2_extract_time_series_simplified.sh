#!/bin/bash

# DESCRIPTION:
# Scripts transforms fMRI data into the MNI space; then, transformed data is
# masked with a collection of masks (each corresponds to a brain region from
# AAL2 atlas) and then the average voxel intensity is computed for the masked
# brain

# TODO:
# - add project home dir as an input
# - remove creation of unused file
# - parallelize computations


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
REFERENCE_ATLAS="/usr/local/fsl/data/standard/MNI152_T1_2mm_brain standard"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Set up export folder
echo
echo "===-===-===-"
echo "Setting up export folder"
TIME_SERIES_FOLDER="."/$DATA_PATH/"time_series_export"
echo "at "$TIME_SERIES_FOLDER

if [[ -e $TIME_SERIES_FOLDER ]]; then
    echo "Folder exists."
    ls $TIME_SERIES_FOLDER
else
    echo "Folder does not exist!"
    echo "Creating."
    mkdir $TIME_SERIES_FOLDER
fi

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Run the analysis

echo
echo "===-===-===-"
echo "Running main analysis"
for i in `seq -f "%03g" 1 $TOTAL_SUBEJCTS`; do
    # Part 1- running filtr
    SUBJECT="$i$NAME_TEMPLATE";
    echo "SUBJECT:" $SUBJECT

    SRC_FILE=./$DATA_PATH/$SUBJECT/"ICA_AROMA/denoised_func_data_nonaggr.nii.gz"

    echo "Processing subject at:"
    echo $SRC_FILE
    echo

    OUT_FOLDER=$TIME_SERIES_FOLDER/$i

    TRASNSFORMATION_MATRIX=./$DATA_PATH/$SUBJECT/"reg/example_func2standard.mat"

    echo "Running flirt..."

    # flirt -ref $REFERENCE_ATLAS -in $SRC_FILE -out $FUNC_TO_STD_OUTPUT -applyxfm -init $TRASNSFORMATION_MATRIX -interp trilinear
    OUT_FILE=./$DATA_PATH/$SUBJECT/"filtered_func_in_MNI.nii.gz"
    flirt -ref $REFERENCE_ATLAS -in $SRC_FILE -out $OUT_FILE -applyxfm -init $TRASNSFORMATION_MATRIX -interp trilinear

    # Part 2- extract signal from masked areas, continue only if flirt suceeded
    echo ""
    echo "===-===-"
    echo "Running signal export:"
    for MASK_FILE in $(ls $MASKS_FOLDER); do
        echo ""
        echo "===-"
        echo "Processing mask:" $MASK_FILE

        OUTPUT_TEXT_FILE=${OUT_FOLDER}/"signals"/$(echo $MASK_FILE | sed 's:\.nii\.gz:\_signal.txt:g')

        if [[ -e $OUTPUT_TEXT_FILE ]]; then
            echo $OUTPUT_TEXT_FILE  " exists."
        else
            fslmeants -i $FUNC_TO_STD_OUTPUT -o $OUTPUT_TEXT_FILE -m $MASKS_FOLDER/$MASK_FILE
        fi
    done
    echo "===-===-"
    echo
done
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Remove reference template file
rm standard

# ===-
echo "Finished processing subjects."
echo "Please inspect results."
