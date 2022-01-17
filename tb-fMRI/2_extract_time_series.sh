#!/bin/bash

# DESCRIPTION:
# Scripts transforms fMRI data into the MNI space; then, transformed data is
# masked with a collection of masks (each corresponds to a brain region from
# AAL2 atlas) and then the average voxel intensity is computed for the masked
# brain

# TODO:
# - add project home dir as an input
# - remove creation of unused file


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
NAME_TEMPLATE=$1
# eg. NAME_TEMPLATE="_FEAT_2022-01-05"

DATA_PATH=$2
# e.g. DATA_PATH="CRT0_processed"

TOTAL_SUBEJCTS=$3

PROC_EXT=$4

FMRI_FILE_NAME=$5

if [ -z "$FMRI_FILE_NAME" ]; then
    echo "Using default FMRI file_name."
    FMRI_FILE_NAME="filtered_func_data"
fi

MATRIX_PATH=$6
if [ -z "$MATRIX_PATH" ]; then
    echo "Using default MATRIX_PATH."
    FMRI_FILE_NAME=$DATA_PATH
fi

MATRIX_TEMPLATE=$7
if [ -z "$MATRIX_TEMPLATE" ]; then
    echo "Using default MATRIX_TEMPLATE."
    FMRI_FILE_NAME=$NAME_TEMPLATE
fi

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
REFERENCE_ATLAS=standard
echo `fslmaths /usr/local/fsl/data/standard/MNI152_T1_2mm_brain standard`

# ===-
# Create reference atlas check
if [[ -e $REFERENCE_ATLAS".nii.gz" ]]; then
    echo "Refernce atlas is correct."
else
    echo "Reference atlas is missing!"
    # echo "Make sure that there exists ./AAl2_masks at the location where script is run!"
    exit
fi

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Source file check
echo
echo "===-===-===-"
echo "Check if source file exists:"
for i in `seq -f "%03g" 1 $TOTAL_SUBEJCTS`; do
    if [ $PROC_EXT == "-" ]; then
        SUBJECT="$i$NAME_TEMPLATE";
    else
        SUBJECT="$i$NAME_TEMPLATE.$PROC_EXT";
    fi

    SRC_FILE=./$DATA_PATH/$SUBJECT/$FMRI_FILE_NAME".nii.gz"
    if [[ -e $SRC_FILE ]]; then
        echo "$SRC_FILE exists"
    else
        echo "$SRC_FILE does not exists!"
    fi
done

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
    if [ $PROC_EXT == "-" ]; then
        SUBJECT="$i$NAME_TEMPLATE";
    else
        SUBJECT="$i$NAME_TEMPLATE.$PROC_EXT";
    fi
    SRC_FILE=./$DATA_PATH/$SUBJECT/$FMRI_FILE_NAME".nii.gz"

    echo "SUBJECT:" $SUBJECT

    echo "Processing subject at:"
    echo $SRC_FILE
    echo

    # TODO this sed is not working correctly
    # OUT_FOLDER=./$TIME_SERIES_FOLDER/$(echo $SUBJECT | sed 's:\.$PROC_EXT:\_mask_signal_export:g')
    OUT_FOLDER=$TIME_SERIES_FOLDER/$i
    if [[ -e $OUT_FOLDER ]]; then
        echo "Output folder exists: " $OUT_FOLDER
    else
        echo "Creating output folder: " $OUT_FOLDER
        mkdir $OUT_FOLDER
    fi

    # Set up paths for filtr
    if [ $PROC_EXT == "-" ]; then
        FUNC_TO_STD_OUTPUT=$OUT_FOLDER/$SUBJECT"_functional_in_std"
    else
        FUNC_TO_STD_OUTPUT=$OUT_FOLDER/$(echo $SUBJECT | sed 's:\.$PROC_EXT:\_functional_in_std:g')
    fi

    FUNC_TO_STD_OUTPUT_FILE=$FUNC_TO_STD_OUTPUT".nii.gz"
    FINAL_MATRIX=$i$MATRIX_TEMPLATE
    TRASNSFORMATION_MATRIX=$MATRIX_PATH/$FINAL_MATRIX/"reg/example_func2standard.mat"

    if [[ -e $FUNC_TO_STD_OUTPUT_FILE ]]; then
        echo $FUNC_TO_STD_OUTPUT " exists."
    else
        echo $FUNC_TO_STD_OUTPUT " does not exists"
        echo "Running flirt..."

        flirt -ref $REFERENCE_ATLAS -in $SRC_FILE -out $FUNC_TO_STD_OUTPUT -applyxfm -init $TRASNSFORMATION_MATRIX -interp trilinear
    fi


    # Part 2- extract signal from masked areas, continue only if flirt suceeded
    if [ "$?" -ne 0 ]; then # if command suceded
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
                fslmeants -i $FUNC_TO_STD_OUTPUT -o $OUTPUT_TEXT_FILE -m $MASKS_FOLDER/$MASK_FILE
            fi
        done
        echo "===-===-"
        echo
    else
        echo "Part 2 not executed, flirt failed to suceed"
    fi # if command suceded
done
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Remove reference template file
rm standard

# ===-
echo "Finished processing subjects."
echo "Please inspect results."
