#!/bin/bash

# DESCRIPTION:
# Scripts transforms fMRI data into the MNI space; then, transformed data is
# masked with a collection of masks (each corresponds to a brain region from
# AAL2 atlas) and then the average voxel intensity is computed for the masked
# brain

# ===-
# Handle input arguments
NAME_TEMPLATE=$1
# eg. NAME_TEMPLATE="_FEAT_2022-01-05"

DATA_PATH=$2
# e.g. DATA_PATH="CRT0_processed"

TOTAL_SUBEJCTS=$3

# ===-
# Global variables set up
REFERENCE_ATLAS=standard
MASKS_FOLDER="./AAl2_masks"

# ===-
# Create reference atlas check
if [[ -e $REFERENCE_ATLAS ]]; then
    echo "Refernce atlas is correct."
else
    echo "Reference atlas is missing!"
    echo "Make sure that there exists ./AAl2_masks at the location where script is run!"
    return
fi

# ===-
# Create reference template file
fslmaths /usr/local/fsl/data/standard/MNI152_T1_2mm_brain standard

# ===-
# Source file check
echo
echo "===-===-===-"
echo "Check if source file exists:"
for i in `seq -f "%03g" 1 $TOTAL_SUBEJCTS`; do
    FILE_NAME="$i$NAME_TEMPLATE.feat";

    SRC_FILE=./$DATA_PATH/$FILE_NAME/"filtered_func_data.nii.gz"
    if [[ -e $SRC_FILE ]]; then
        echo "$SRC_FILE exists"
    else
        echo "$SRC_FILE does not exists!"
    fi
done

# ===-
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

# ===-
# Run the analysis

echo
echo "===-===-===-"
echo "Running main analysis"
for i in `seq -f "%03g" 1 $TOTAL_SUBEJCTS`; do
    # Part 1- running filtr
    SUBJECT="$i$NAME_TEMPLATE.feat";
    SRC_FUNC_DATA=./$DATA_PATH/$SUBJECT/"filtered_func_data.nii.gz"

    echo "Processing subject at:"
    echo $SRC_FUNC_DATA
    echo

    OUT_FOLDER=$(echo $SUBJECT | sed 's:\.feat:\_results:g')
    if [[ -e $OUT_FOLDER ]]; then
        echo "Output folder exists: " $OUT_FOLDER
    else
        echo "Creating outpu folder: " $OUT_FOLDER
        mkdir $OUT_FOLDER
    fi

    # Set up paths for filtr
    FUNC_STD_OUT=$OUT_FOLDER/$(echo $SUBJECT | sed 's:\.feat:\_functional_in_std:g')
    FUNC_STD_OUT_FILE=$FUNC_STD_OUT".nii.gz"
    TRASNSFORMATION_MATRIX=$DATA_PATH/$SUBJECT/"reg/example_func2standard.mat"

    if [[ -e $FUNC_STD_OUT_FILE ]]; then
        echo $FUNC_STD_OUT " exists."
    else
        echo $FUNC_STD_OUT " does not exists"
        echo "Running flirt..."
        flirt -ref $REFERENCE_ATLAS -in $SRC_FUNC_DATA -out $FUNC_STD_OUT -applyxfm -init $TRASNSFORMATION_MATRIX -interp trilinear
    fi

    # Part 2- getting signals with masks
    if [[ -e $OUT_FOLDER/"signals" ]]; then
        echo $OUT_FOLDER/"signals" " exists."
    else
        echo "Folder does not exist."
        echo "Creating: " $OUT_FOLDER/"signals"
        mkdir $OUT_FOLDER/"signals"
    fi

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
            fslmeants -i $FUNC_STD_OUT -o $OUTPUT_TEXT_FILE -m $MASKS_FOLDER/$MASK_FILE
        fi
    done
    echo "===-===-"
    echo
done
echo "===-===-===-===-"

# ===-
# Remove reference template file
rm standard

# ===-
echo "Finished processing subjects."
echo "Please inspect results."
