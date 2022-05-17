#!/bin/bash

set -e


MASKS_PATH=$1

EXPORT_DIR=$2


if [[ -e "${EXPORT_DIR}" ]]; then
    echo "=> Output folder exists"
else
    mkdir "${EXPORT_DIR}"
fi

echo $MASKS_PATH

for k in $(ls $MASKS_PATH); do
    BRAIN_MASK_FILE="${MASKS_PATH}/${k}"
    BRAIN_AREA=`echo $k | sed 's:\.nii\.gz::g'`
    OUTPUT_FILE="${EXPORT_DIR}/${BRAIN_AREA}_"

    echo "=> >>>"
    echo "=> Doing fsl2ascii on ${BRAIN_AREA}"
    fsl2ascii "${BRAIN_MASK_FILE}" "${OUTPUT_FILE}"
    echo "=> fsl2ascii done."
    echo "=> <<<"
done
