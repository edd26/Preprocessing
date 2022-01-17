#!/bin/bash

# DESCRIPTION:
# Applies AROMA-ICA to remove motion artifacts from the FEAT processed data
# This script has to be run from within python2 environment


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
NAME_TEMPLATE=$1
# eg. NAME_TEMPLATE="_FEAT_2022-01-05"

DATA_PATH=$2
# e.g. DATA_PATH="CRT0_processed"

TOTAL_SUBEJCTS=$3

# PROC_EXT=$4
OUT_DIR=$4

# ICA-AROMA path
ICA_AROMA_PATH=$5

# AROMA-ICA required file
MCFLIRT_PATH=$6

# AROMA-ICA required file
MCFLIRT_FILE=$7


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Report pwd
HOME=`pwd`
echo "pwd: " `pwd`

# ===-
# Global variables set up

echo "===-===-===-"
for i in `seq -f "%03g" 1 $TOTAL_SUBEJCTS`; do

    FILE_NAME="$i"
    OUT_FOLDER="$i-$OUT_DIR"

    MCFIRT_SUBPATH=$i"_"$MCFLIRT_FILE
    MCFLIRT_FILE_SUB=$MCFLIRT_PATH/$MCFIRT_SUBPATH/"mc/prefiltered_func_data_mcf.par"

    echo "Running for file:" $FILE_NAME
    echo "OUT_FOLDER" $OUT_FOLDER
    echo "MCFIRT_SUBPATH" $MCFIRT_SUBPATH
    echo "MCFLIRT_FILE_SUB" $MCFLIRT_FILE_SUB

    python $HOME/$ICA_AROMA_PATH/"ICA_AROMA.py" -in $HOME/$DATA_PATH/$FILE_NAME".nii" -o $HOME/$OUT_FOLDER -mc $HOME/$MCFLIRT_FILE_SUB
done

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
echo "Finished processing subjects."
echo "Please inspect results."
echo "===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-"
