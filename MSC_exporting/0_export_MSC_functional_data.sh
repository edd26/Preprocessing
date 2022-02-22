#!/bin/bash

set -e

# DESCRIPTION:
# Export `gz` files to `ni` files in the same location as the first one.


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ARGS loading

SUBJECT_START=$1
SUBJECT_STOP=$2

TOTAL_SESSIONS=$3

DATA_LOCATION=$4

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Report pwd
echo "pwd: " `pwd`

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
echo
echo "===-===-===-"
echo "Running MSC export"
for i in `seq -f "%02g" ${SUBJECT_START} ${SUBJECT_STOP}`; do

    SUBJECT_NAME="sub-MSC$i"
    echo "=>Working on subject: " $SUBJECT_NAME
    for k in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do
        SESSION_NAME="ses-func$k"
        echo "==>Working on session: " $SESSION_NAME

        for t in "glasslexical_run-01" "glasslexical_run-02" "memoryfaces" "memoryscenes" "memorywords" "motor_run-01"  "motor_run-02"; do
            TASK_NAME="${SUBJECT_NAME}_${SESSION_NAME}_task-${t}_bold"
            echo "===> TASK_NAME " $TASK_NAME

            IN_FILE="${DATA_LOCATION}/${SUBJECT_NAME}/${SESSION_NAME}/func/${TASK_NAME}.nii.gz"
            OUT_FILE="${DATA_LOCATION}/${SUBJECT_NAME}/${SESSION_NAME}/func/${TASK_NAME}.nii"
            REAL_NAME=`realpath "$IN_FILE"`

            echo "===> IN FILE" $IN_FILE

            # realpath "$IN_FILE" | extract_file
            # echo "IN_FILE " $IN_FILE
            # echo "OUT_FILE " $OUT_FILE
            # echo "REAL_NAME " $REAL_NAME

            # tar xf "$REAL_NAME"
            gzip --keep -d "$REAL_NAME"
            EXTRACTED_NAME=`echo $REAL_NAME | sed 's:\.gz$::g'`
            # echo "===> Extracted name " $EXTRACTED_NAME

            mv "${EXTRACTED_NAME}" "${OUT_FILE}"
        done
    done
done
echo "===-===-===-===-"

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# ===-
# echo "Finished processing subjects."
# echo "Please inspect results."
