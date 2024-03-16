#!/bin/bash

source /devops/scripts/vars.sh

execution_id=$1
project=$2
caller_class=$3
callee_class=$4

# 1- run cling with the right configurations
CPEntriesDir="$PROJECT_DIR/$project/cp-entries.txt"
CPEntriesContent=$( cat $CPEntriesDir)
preparedCPs=$( python "$SCRIPT_DIR/python/reassemble-cps.py" $CPEntriesContent "$project")

java -d64 -Xmx4000m -jar tools/cling.jar -project_cp "$preparedCPs" -target_classes "$caller_class:$(echo -e "$callee_class" | tr -d '[:space:]')" -fitness "Branch_Pairs" "-Dsandbox=true" "-Dsearch_budget=$BUDGET" -Dtest_dir="$RESULT_DIR/$project-$caller_class-$callee_class-$execution_id" > "$LOG_DIR/$project-$caller_class-$callee_class-$execution_id-out.txt" 2> "$LOG_DIR/$project-$caller_class-$callee_class-$execution_id-err.txt" &
pid=$!

# 2- call observe
. "$SCRIPT_DIR/bash/cling-observer.sh" $pid "$project-$caller_class-$callee_class-$execution_id-out.txt" $execution_id $project $caller_class $callee_class &
