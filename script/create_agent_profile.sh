#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

ORIGINAL_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SERVICE=$1
BASE_PATH="../pipelines"
CHART_PATH="../templates/gocd"
SERVER_CHART_PATH="../templates/server"
ENVIRONMENTS=("prod" "stag")

function check_and_install_yq {
    if ! command -v yq &> /dev/null; then
        echo "yq is not installed. Installing yq..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install yq
        else
            echo "Unsupported OS. Please install yq manually."
            exit 1
        fi
    else
        echo "yq is already installed."
    fi
}

check_and_install_yq

SERVICE_EXISTS=false
for ENV in "${ENVIRONMENTS[@]}"; do
    if [ -d "$BASE_PATH/$ENV/$SERVICE" ]; then
        SERVICE_EXISTS=true
        break
    fi
done

if [ "$SERVICE_EXISTS" = false ]; then
    echo "Error: Service '$SERVICE' not found in any environment"
    exit 1
fi

for ENV in "${ENVIRONMENTS[@]}"; do
    if [ -d "$BASE_PATH/$ENV/$SERVICE" ]; then
        VALUES_FILE="$BASE_PATH/$ENV/$SERVICE/values.yaml"
        echo $VALUES_FILE

        if [ ! -f "$VALUES_FILE" ]; then
            echo "Warning: values.yaml not found for $SERVICE in $ENV environment"
            continue
        fi

        NAME=$(yq eval '.name' "$VALUES_FILE")
        ENVIRONMENT=$(yq eval '.environment' "$VALUES_FILE")
        BUILD_PROFILE_ID=$NAME-$ENVIRONMENT-agent-profile
        echo "Processing profile: $BUILD_PROFILE_ID"

        cd "$SCRIPT_DIR"

        POD_TEMPLATE=$(./split_yaml_by_source.sh "$(helm template "$SERVICE" "$CHART_PATH" -f "$VALUES_FILE")" gocd/templates/elastic-agent.yaml | awk '{printf "%s\\n", $0}' | sed 's/"/\\"/g')

        curl "https://gocd.xquare.app/go/api/elastic/profiles" \
             -u "${{ GOCD_USERNAME }}:${{ GOCD_PASSWORD }}" \
             -H 'Accept: application/vnd.go.cd.v2+json' \
             -H 'Content-Type: application/json' \
             -X POST -d "{
               \"id\": \"$BUILD_PROFILE_ID\",
               \"cluster_profile_id\": \"k8-cluster-profile\",
               \"plugin_id\": \"cd.go.contrib.elasticagent.kubernetes\",
               \"properties\": [
                 {
                   \"key\": \"Image\"
                 },
                 {
                   \"key\": \"MaxMemory\"
                 },
                 {
                   \"key\": \"MaxCPU\"
                 },
                 {
                   \"key\": \"Environment\"
                 },
                 {
                   \"key\": \"PodConfiguration\",
                   \"value\": \"$POD_TEMPLATE\"
                 },
                 {
                   \"key\": \"SpecifiedUsingPodConfiguration\"
                 },
                 {
                   \"key\": \"PodSpecType\",
                   \"value\": \"yaml\"
                 },
                 {
                   \"key\": \"RemoteFile\"
                 },
                 {
                   \"key\": \"RemoteFileType\",
                   \"value\": \"json\"
                 },
                 {
                   \"key\": \"Privileged\"
                 }
               ]
             }"

        ./split_yaml_by_source.sh "$(helm template "$SERVICE" "$SERVER_CHART_PATH" -f "$VALUES_FILE")" applications/templates/elastic-agent-pvc.yaml > elastic-agent-pvc.yaml
        cat elastic-agent-pvc.yaml
        kubectl apply -f elastic-agent-pvc.yaml

        cd "$ORIGINAL_DIR"
    else
        echo "Service '$SERVICE' not found in $ENV environment"
    fi
done

rm elastic-agent-pvc.yaml