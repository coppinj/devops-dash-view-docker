#!/usr/bin/env bash

source /devops/scripts/vars.sh

# Check input CSV file
SUBJECTS_PATH="$DATA_DIR/subjects.csv"

if [ ! -f $SUBJECTS_PATH ]; then
  echo "$SUBJECTS_PATH file not found"

  exit 1
fi

# Add new separator
OLDIFS=$IFS
IFS=,

# number of parallel processes
LIMIT=$1

# Prepare job lists
echo "[INFO] Reading tasks"
JOB_LIST=()

COUNTER=0

while read execution_id project caller_class callee_class type
do
  # skip the title row
  if [[ "$COUNTER" -eq "0" ]]; then
    COUNTER=1
    continue
  fi

  task_json=$(python "$SCRIPT_DIR/python/task_to_string.py" $execution_id $project $caller_class $callee_class)
  JOB_LIST+=($task_json)

done < $SUBJECTS_PATH

# Here, we have the list of jobs in JOB_LIST
echo "[INFO] The number of tasks is "${#JOB_LIST[@]}""

LOOP_MAX_ITERATIONS=$MAX_ITERATIONS

if [ "$MAX_ITERATIONS" -lt "0" ]; then
  LOOP_MAX_ITERATIONS=${#JOB_LIST[@]}
fi

if [ ${#JOB_LIST[@]} -gt "$MAX_ITERATIONS" ]; then
  echo "[INFO] The max iterations is smaller than the number of test to generate. The number of test to generate will be adapted to : $MAX_ITERATIONS"
fi

COUNTER=0
MAX_ITERATIONS_EXCEEDED=0

for t in "${JOB_LIST[@]}"; do
  if [ "$LOOP_MAX_ITERATIONS" -eq "0" ]; then
    MAX_ITERATIONS_EXCEEDED=1
    break
  fi

  ((COUNTER++))
  # Read values
  execution_id=$(python "$SCRIPT_DIR/python/get_from_json.py" $t "execution_id")
  project=$(python "$SCRIPT_DIR/python/get_from_json.py" $t "project")
  caller_class=$(python "$SCRIPT_DIR/python/get_from_json.py" $t "caller_class")
  callee_class=$(python "$SCRIPT_DIR/python/get_from_json.py" $t "callee_class")

  echo "[INFO] Task #$COUNTER for the $execution_id(th) time on project $project. caller class: $caller_class, callee class: $callee_class"
  . "$SCRIPT_DIR/bash/run_cling.sh" $execution_id $project $caller_class $callee_class

  # Stop the script execution if we reach to the indicated maximum number of parallel processes
  while (( $(ps -ef | grep '[j]ava' | grep -v defunct | wc -l) >= LIMIT ))
  do
    sleep 1
  done

  if [ "$COUNTER" -ge "$LOOP_MAX_ITERATIONS" ]; then
    MAX_ITERATIONS_EXCEEDED=1
    break
  fi
done

if [ $MAX_ITERATIONS_EXCEEDED -eq 1 ]; then
  echo "[INFO] Max number of iterations exceeded. Waiting for processes to complete before exiting"

  while (( $(ps -ef | grep '[j]ava' | grep -v defunct | wc -l) > 0 ))
  do
    sleep 1
  done

  sleep 5
fi

if [ "$(pgrep java | wc -l)" -gt 0 ]; then
  pgrep java | xargs kill -9
fi

echo "[SUCCESS] Process is finished."
