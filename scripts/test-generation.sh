#!/usr/bin/env bash

# Check input CSV file
SUBJECTS_PATH="subject_generator/subjects.csv"
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
echo "Reading tasks"
JOB_LIST=()

COUNTER=0

while read tool execution_id project caller_class callee_class type
do
  # skip the title row
  if [[ "$COUNTER" -eq "0" ]]; then
    COUNTER=1
    continue
  fi

  task_json=$(python scripts/python/test-generation/task_to_string.py $tool $execution_id $project $caller_class $callee_class)
  JOB_LIST+=($task_json)

done < $SUBJECTS_PATH

# Here, we have the list of jobs in JOB_LIST
echo "The number of tasks is "${#JOB_LIST[@]}""

# Start the test generation

COUNTER=0
for t in "${JOB_LIST[@]}"; do
  ((COUNTER++))
  # Read values
  tool=$(python scripts/python/test-generation/get_from_json.py $t "tool")
  execution_id=$(python scripts/python/test-generation/get_from_json.py $t "execution_id")
  project=$(python scripts/python/test-generation/get_from_json.py $t "project")
  caller_class=$(python scripts/python/test-generation/get_from_json.py $t "caller_class")
  callee_class=$(python scripts/python/test-generation/get_from_json.py $t "callee_class")

  echo "Task #$COUNTER executes $tool for the $execution_id(th) time on project $project. caller class: $caller_class, callee class: $callee_class"
  . scripts/run/run_cling.sh $execution_id $project $caller_class $callee_class

  # Stop the script execution if we reach to the indicated maximum number of parallel processes
  while (( $(pgrep -l java | wc -l) >= $LIMIT ))
  do
    sleep 1
  done
done

#After finishing tasks, wait for tools to finish their test generation processes.
while (( $(pgrep -l java | wc -l) > 0 ))
do
  sleep 60
  # Check if all of the tests are generated
  finished=true
  while read tool execution_id project caller_class callee_class
    do
      if [[ "$tool" == evosuite-callee* ]]; then
        resultDir="results/evosuite5/$project-$callee_class-$execution_id"
      elif [[ "$tool" == evosuite-caller* ]]; then
        resultDir="results/evosuite5/$project-$caller_class-$execution_id"
      elif [[ "$tool" == "botsing" ]]; then
        resultDir="results/$tool/$project-$caller_class-$callee_class-$execution_id"
      elif [[ "$tool" == randoop-callee* ]]; then
        resultDir="results/randoop5/$project-$callee_class-$execution_id"
      elif [[ "$tool" == randoop-caller* ]]; then
        resultDir="results/randoop5/$project-$caller_class-$execution_id"
      fi

      if [ ! -d "$resultDir" ]; then
        echo "$resultDir is not available yet!"
        finished=false
        break
      fi
    done

    if [ "$finished" = true ] ; then
      echo 'Killing all of the processes'
      kill -9 $(pgrep java)
    fi
done

echo "Process is finished."
