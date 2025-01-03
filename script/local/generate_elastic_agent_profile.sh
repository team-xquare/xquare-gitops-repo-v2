#!/bin/bash

BASE_PATH="../pipelines"
CHART_PATH="../templates/gocd"
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
        ./create_agent_profile.sh $SERVICE
    done
done
