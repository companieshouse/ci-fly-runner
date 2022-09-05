#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <file_name>"
  echo "Example: $0 pipeline_list.txt"
  exit 1
fi

declare -a PIPELINE_NAME_ARRAY
declare -a PIPELINE_ERROR_ARRAY

validate-pipeline() {
  printf "Validating pipeline: $1... "

  local output;
  output=$(fly validate-pipeline -s -c $1 2>&1)

  if [[ $? -ne 0 ]]; then
    printf "validation failure\n"
    VALIDATION_ERROR=1
    PIPELINE_NAME_ARRAY+=("$1")
    PIPELINE_ERROR_ARRAY+=("$output")
  else
    printf "${output}\n"
  fi
}

## Main script start

for PIPELINE in $(cat $1); do
  validate-pipeline $PIPELINE
done

if [[ ! -z $VALIDATION_ERROR ]]; then
  echo "----------------------------------------"
  echo "The following pipelines failed validation:"
  LENGTH=${#PIPELINE_NAME_ARRAY[@]}
  for (( j=0; j<${LENGTH}; j++ )); do
    pipeline=${PIPELINE_NAME_ARRAY[$j]}
    error=${PIPELINE_ERROR_ARRAY[$j]}
    echo "${pipeline}: ${error}"
  done

  exit 1
else
  exit 0
fi
