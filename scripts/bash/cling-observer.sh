#!/bin/bash

source /devops/scripts/vars.sh

pid=$1
filename=$2
execution_id=$3
project=$4
caller_class=$5
callee_class=$6

resultDir="$RESULT_DIR/$project-$caller_class-$callee_class-$execution_id"

stopLoop=0
while [ "$stopLoop" -eq 0 ]; do
    # First, sleep and wait for the process to finish
    sleep "1"
    # Find inactive time
    modifiedTime=$(date -r "$LOG_DIR/$filename" "+%s")
    currentTime=$(date "+%s")
    inActiveTime=$((currentTime-modifiedTime))
#    echo "Process $pid is inactive for $inActiveTime seconds"

    if ! kill -0 "$pid" > /dev/null 2>&1; then
        echo "[SUCCESS] Test is generated. id: $execution_id project $project caller class: $caller_class callee class:$callee_class -> PID has completed"

        stopLoop=1
    elif [[ "$inActiveTime" -gt "$BUDGET" ]]; then
        kill "$pid"

        if [ -d "$resultDir" ]; then
            echo "[SUCCESS] Test is generated. id: $execution_id project $project caller class: $caller_class callee class:$callee_class -> PID was killed"
        else
            echo "[ERROR] Test was not generated. id: $execution_id project $project caller class: $caller_class callee class:$callee_class -> TIMEOUT"
        fi

        stopLoop=1
    fi
done
