function get_BET_done(){
    
    # SUBJECT="sub-MSC${i}_ses-func${f}_task-${TASK}_bold"
    SUBJECT="$(get_file_name i f TASK r 1)";
    IN_FILE=$DATA_PATH/$SUBJECT
    FULL_IN_FILE="${IN_FILE}${EXTENSION}"
    OUT_FILE="${IN_FILE}_brain.nii.gz"
    
    if [[ -e $FULL_IN_FILE ]]; then
        echo "Input file exists!"
    else
        echo "Input file does not exists!"
    fi
    echo $FULL_IN_FILE
    
    if [[ -e $OUT_FILE ]]; then
        echo $OUT_FILE
        echo " file exists. Skipping..."
    else
        echo "Running BET"
        echo $BET_PATH $IN_FILE $OUT_FILE -F -f $F_VAL -g 0
        
        $BET_PATH $IN_FILE $OUT_FILE -F -f $F_VAL -g 0
    fi
}

function get_file_name(){
    i=$1
    f=$2
    TASK=$3
    r=$4
    BRAIN_NOT_APPEND=$5
    
    NAME="sub-MSC${i}_ses-func${f}_task-${TASK}"
    # Check task, add run if there can be one
    if [[ "${TASK}" == "motor" ]] || [[ "${TASK}" == "glasslexical" ]]; then
        
        NAME="${NAME}_run-${r}"
    fi
    
    
    
    if [ -z ${BRAIN_NOT_APPEND+x} ]; then
        # echo "var is unset"
        FINAL_NAME="${NAME}_bold_brain"
    else
        # echo "var is set to '$var'"
        FINAL_NAME="${NAME}_bold"
    fi
    
    
    return FINAL_NAME
}

function get_session_name(){
    i=$1
    f=$2
    TASK=$3
    r=$4
    
    NAME="MSC${i}_ses${f}_${TASK}"
    # Check task, add run if there can be one
    if [[ "${TASK}" == "motor" ]] || [[ "${TASK}" == "glasslexical" ]]; then
        
        # TODO not all sessions with those tasks have another run- this have to be checked somewhere, but rather not here
        
        NAME="${NAME}_run${r}"
    fi
    
    return NAME
}