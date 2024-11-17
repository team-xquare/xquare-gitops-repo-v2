#!/bin/bash

BASE_PATH="pipelines"
CHART_PATH="templates/gocd"
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

for ENV in "${ENVIRONMENTS[@]}"; do
    for SERVICE in $(ls "$BASE_PATH/$ENV"); do
        pwd
        VALUES_FILE="./$BASE_PATH/$ENV/$SERVICE/values.yaml"
        NAME=$(yq eval '.name' "$VALUES_FILE")
        ENVIRONMENT=$(yq eval '.environment' "$VALUES_FILE")
        BUILD_PROFILE_ID=$NAME-$ENVIRONMENT-agent-profile
        echo $BUILD_PROFILE_ID

        POD_TEMPLATE=$(./split_yaml_by_source.sh "$(helm template "$SERVICE" "$CHART_PATH" -f "$VALUES_FILE")" gocd/templates/elastic-agent.yaml | awk '{printf "%s\\n", $0}' | sed 's/"/\\"/g')

        ETAG=$(curl -s -I -X GET "https://gocd.xquare.app/go/api/elastic/profiles/$BUILD_PROFILE_ID" \
               -u "${{ GOCD_USERNAME }}:${{ GOCD_PASSWORD }}" \
               -H 'Accept: application/vnd.go.cd.v2+json' | grep etag | awk '{print $2}' | tr -d '\r')

        echo "Fetched ETag: $ETAG"

        curl "https://gocd.xquare.app/go/api/elastic/profiles/$BUILD_PROFILE_ID" \
             -H 'Accept: application/vnd.go.cd.v2+json' \
             -H 'Content-Type: application/json' \
             -H "If-Match: $ETAG" \
             -X PUT -d "{
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

        ./split_yaml_by_source.sh "$(helm template "$SERVICE" "$CHART_PATH" -f "$VALUES_FILE")" server/templates/elastic-agent-pvc.yaml > elastic-agent-pvc.yaml
        kubectl apply -f elastic-agent-pvc.yaml
    done
done
