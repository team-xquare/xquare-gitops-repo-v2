#!/bin/bash

BASE_PATH="pipelines"
CHART_PATH="templates/gocd"
ENVIRONMENTS=("prod" "stag")

for ENV in "${ENVIRONMENTS[@]}"; do
  for SERVICE in $(ls "$BASE_PATH/$ENV"); do
    pwd
    VALUES_FILE="./$BASE_PATH/$ENV/$SERVICE/values.yaml"
    OUTPUT_FILE="./$BASE_PATH/$ENV/$SERVICE/$SERVICE-$ENV-pipeline.gocd.yaml"

    ./script/split_yaml_by_source.sh "$(helm template $SERVICE $CHART_PATH -f $VALUES_FILE)" gocd/templates/pipeline.yaml > $OUTPUT_FILE
  done
done