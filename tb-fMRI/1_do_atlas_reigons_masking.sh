#!/bin/bash


ATLAS_REIONGS_FOLDER="./aal2/regions_masks/Brain/"
# ls $ATLAS_REIONGS_FOLDER

MASKS_OUTPUT_FOLDER="./AAl2_masks"

if [[ -e $MASKS_OUTPUT_FOLDER ]]; then
    echo "Folder exists."
    ls $MASKS_OUTPUT_FOLDER
else
    echo "Folder does not exist!"
    echo "Creating."
    mkdir $MASKS_OUTPUT_FOLDER
fi

# for INPUT_REGION_FILE in ATLAS_REIONGS_FOLDER
for INPUT_REGION_FILE in $(ls $ATLAS_REIONGS_FOLDER); do
# INPUT_REGION_FILE="Caudate_R.nii"
    echo "Working on $INPUT_REGION_FILE"

    INPUT_REGION_NAME=$(echo $INPUT_REGION_FILE | sed 's:\.nii::g')
    MASK_NAME="${INPUT_REGION_NAME}_mask.nii"

    # echo $INPUT_REGION_FILE
    # echo $INPUT_REGION_NAME
    # echo $MASK_NAME

    SRC_FILE=$ATLAS_REIONGS_FOLDER/$INPUT_REGION_FILE
    TRGT_FILE=$MASKS_OUTPUT_FOLDER/$MASK_NAME
    # echo $SRC_FILE
    # echo $TRGT_FILE
    fslmaths $SRC_FILE -thr 0.5 -bin $TRGT_FILE
done

echo "Finished processing masks."
echo "Please inspect results."
