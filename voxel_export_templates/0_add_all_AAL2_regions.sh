#!/bin/bash

set -e

# DESCRIPTION:
#

# Global variables set up
# MASKS_FOLDER="./AAl2_masks"
MASKS_FOLDER=$1
echo "Masks folder: " $MASKS_FOLDER

OUT_FILE=$2
PRE_ADDITION_MASK="${OUT_FILE}_pre.nii.gz"
POST_ADDITION_MASK="${OUT_FILE}_post.nii.gz"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Run the analysis

PWD_FOLDER=`pwd`

# Create an fiile with empty MNI space
echo "Creating empty  space"
fslmaths "${MASKS_FOLDER}/Amygdala_L_mask.nii.gz" -mul "${MASKS_FOLDER}/Amygdala_R_mask.nii.gz" "${PRE_ADDITION_MASK}"
# fslmaths "${MASKS_FOLDER}/Amygdala_L_mask.nii.gz" -mul "${MASKS_FOLDER}/Amygdala_R_mask.nii.gz" "${POST_ADDITION_MASK}"

echo "Running masks addition:"
for MASK_FILE in $(ls $MASKS_FOLDER); do
    MASK="${MASKS_FOLDER}/${MASK_FILE}"
    echo ${PRE_ADDITION_MASK}
    echo ${MASK}
    echo ${POST_ADDITION_MASK}

    fslmaths ${PRE_ADDITION_MASK} -add ${MASK} ${POST_ADDITION_MASK}
    # rm ${PRE_ADDITION_MASK}
    mv ${POST_ADDITION_MASK} ${PRE_ADDITION_MASK}
done
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
echo "Finished processing subjects."
echo "Please inspect results."
