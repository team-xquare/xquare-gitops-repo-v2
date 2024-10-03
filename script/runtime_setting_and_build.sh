#!/bin/sh

if [ $# -eq 0 ]; then
    echo "Error: JSON file path not provided"
    echo "Usage: $0 <path_to_json_file>"
    exit 1
fi

JSON_FILE="$1"

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found at $JSON_FILE"
    exit 1
fi

parse_json() {
    jq -r "$1" < "$JSON_FILE"
}

select_or_install_jdk() {
    echo "Debug"
    whoami
    version=$1
    if update-java-alternatives -l | grep "java-1.$version"; then
        update-java-alternatives -s java-1.$version.0-openjdk-amd64
    else
        echo "JDK $version not found. Installing..."
        apt-get update
        apt-get install -y openjdk-${version}-jdk
    fi
}

select_or_install_node() {
    version=$1
    if command -v nvm > /dev/null 2>&1; then
        if nvm ls "$version" > /dev/null 2>&1; then
            nvm use "$version"
        else
            echo "Node.js $version not found. Installing..."
            nvm install "$version"
            nvm use "$version"
        fi
    else
        echo "NVM not found. Installing NVM and Node.js $version"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install "$version"
        nvm use "$version"
    fi
}

builder=$(parse_json '.builder')

case "$builder" in
    "gradle")
        jdk_version=$(parse_json '.jdk_version')

        echo "Selecting or installing JDK version $jdk_version"
        select_or_install_jdk "$jdk_version"

        java -version
        ;;
    "node")
        node_version=$(parse_json '.node_version')

        if [ -z "$node_version" ]; then
            echo "Error: node_version not found in JSON data"
            exit 1
        fi

        echo "Selecting or installing Node.js version $node_version"
        select_or_install_node "$node_version"

        node --version
        ;;
    *)
        echo "Unsupported builder: $builder"
        exit 1
        ;;
esac

echo "Runtime setup completed successfully"

echo "Starting build process"
build_commands=$(parse_json '.build_commands[]')

build_dir=$(parse_json '.build_dir')

echo "Move Directory"

if [ -z "$build_dir" ]; then
  echo "build_dir is not set, moving to root directory"
  cd ./
else
  if [ "${build_dir#/}" != "$build_dir" ]; then
    build_dir=".$build_dir"
  fi
  if [ -d "$build_dir" ]; then
    cd "$build_dir"
  else
    echo "Directory $build_dir does not exist."
    exit 1
  fi
fi

echo "Executing: $build_commands"
eval "$build_commands"
if [ $? -ne 0 ]; then
    echo "Build command failed: $build_commands"
    exit 1
fi

echo "Build process completed successfully"
