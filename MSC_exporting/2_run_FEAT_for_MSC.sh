#!/bin/bash

# DESCRIPTION:
# Run FEAT for all given sequence of subjects and then appy AROMA to remove noise
#
# ASSUMPTIONS:
#

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
set -e

source naming_functions.sh

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Handle input arguments
SUBEJCTS_MIN=$1
SUBEJCTS_MAX=$2
TOTAL_SESSIONS=$3
TOTAL_RUNS=$4

TEMPLATE_DESIGN_FILE=$5
# e.g. ICA_AROMA

TASK=$6
# e.g. motor

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Set up CONSTANTS
PWD_FOLDER=`pwd`

FSL_INTERFACE_SCRIPTS="${HOME}/Programming/Python/fsl-design-file-interface"

# Runs
function get_FEAT_done(){  # ===-===-
    get_file_name $i $f $TASK $r 0
    # SUBJECT="sub-MSC${i}_ses-func${f}_task-${TASK}_run-${r}_bold_brain";
    SUBJECT=$FINAL_NAME
    
    FEAT_FOLDER=$DATA_PATH/$SUBJECT".feat"
    echo "===-===-"
    echo "Running FEAT."
    if [[ -e $FEAT_FOLDER ]]; then
        echo $FEAT_FOLDER " exists."
    else
        # echo $BOLD_IN_MNI " does not exists"
        echo "Creating FEAT folder..."
        
        # Set up variables
        FUNC_PATH="0${i}"/"ses-func${f}"/"func"
        STRUCT_PATH="0${i}"/"ses-struct01"
        
        FUNCTIONAL_FILE="${PWD_FOLDER}/${FUNC_PATH}/${SUBJECT}"
        STRUCTURAL_FILE="${PWD_FOLDER}/${STRUCT_PATH}/sub-MSC${i}_ses-struct01_run-01_T1w_brain"
        
        echo "Fjnctional file" $FUNCTIONAL_FILE
        echo "Structural file" $STRUCTURAL_FILE
        
        # RUN FEAT
        # 1. make a local copy of design file
        cp $TEMPLATE_DESIGN_FILE $PWD_FOLDER/"design_local.fsf"
        
        # 2. Change path of the functional file
        python ${FSL_INTERFACE_SCRIPTS}/set_option.py -i design_local.fsf -o design_local1.fsf -k "feat_files" -v ${FUNCTIONAL_FILE}
        
        # 3. Change path of the structural file
        python ${FSL_INTERFACE_SCRIPTS}/set_option.py -i design_local1.fsf -o design_local2.fsf -k "highres_files" -v ${STRUCTURAL_FILE}
        
        # 4. Run feat with design file
        echo "Runnig feat command"
        feat design_local2.fsl
        
    fi
    
    echo "===-===-===-===-"
    echo
}
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Run the analysis

echo
echo "===-===-===-"
echo "Running FEAT"
# Subjects
for i in `seq -f "%02g" $SUBEJCTS_MIN $SUBEJCTS_MAX`; do
    
    # Sessions
    for f in `seq -f "%02g" 1 $TOTAL_SESSIONS`; do
        DATA_PATH=$PWD_FOLDER/"0${i}"/"ses-func${f}"/"func"
        
        # for TASK in "glasslexical" "memoryfaces" "memoryscenes" "memorywords" "motor"; do
        
        if [[ "${TASK}" == "motor" ]] || [[ "${TASK}" == "glasslexical" ]]; then
            LOCAL_TOTAL_RUNS=$TOTAL_RUNS
        else
            LOCAL_TOTAL_RUNS=1
        fi # tasks
        
        for r in `seq -f "%02g" 1 ${LOCAL_TOTAL_RUNS}`; do
            get_FEAT_done
        done # r
        # done # TASK
        
    done # f
done # i
echo "Finished FEAT computations"
echo "===-===-===-===-"

