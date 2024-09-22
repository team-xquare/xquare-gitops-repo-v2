#!/bin/bash

if ! command -v jinja2 &> /dev/null; then
    echo "Jinja2 is not installed. Installing..."
    pip install jinja2-cli
fi

PROJECT_ROOT="."

ENVIRONMENTS=("prod" "stag")

GRADLE_TEMPLATE="$PROJECT_ROOT/templates/dockerfile/templates/Dockerfile_use_gradle.template"
NODE_TEMPLATE="$PROJECT_ROOT/templates/dockerfile/templates/Dockerfile_use_node.template"
NODE_NGINX_TEMPLATE="$PROJECT_ROOT/templates/dockerfile/templates/Dockerfile_use_node_with_nginx.template"

update_dockerfile() {
    local env=$1
    local service=$2
    local template_json_dir="$PROJECT_ROOT/pipelines/$env/$service/template.json"
    local template_json=$template_json_dir
    local dockerfile="$PROJECT_ROOT/pipelines/$env/$service/Dockerfile"

    if [ ! -f "$template_json" ]; then
        echo "template.json not found for $service in $env environment. Skipping..."
        return
    fi

    local builder=$(jq -r '.builder // empty' "$template_json")

    case "$builder" in
        "gradle")
            jq '.build_commands[0] += " --build-cache"' $template_json_dir > temp.json && mv temp.json $template_json_dir
            template="$GRADLE_TEMPLATE"
            ;;
        "node")
            template="$NODE_TEMPLATE"
            ;;
        "node_with_nginx")
            template="$NODE_NGINX_TEMPLATE"
            ;;
        *)
            echo "Unknown builder type for $service in $env environment. Skipping..."
            return
            ;;
    esac

    echo "Updating Dockerfile for $service in $env environment..."
    jinja2 "$template" "$template_json" -o "$dockerfile"
    echo "Dockerfile updated for $service in $env environment."
}

for env in "${ENVIRONMENTS[@]}"; do
    env_dir="$PROJECT_ROOT/pipelines/$env"
    for service_dir in "$env_dir"/*; do
        if [ -d "$service_dir" ]; then
            service=$(basename "$service_dir")
            update_dockerfile "$env" "$service"
        fi
    done
done

echo "All Dockerfiles have been updated."