#!/bin/sh

if [ $# -eq 0 ]; then
    echo "Error: JSON 파일 경로가 제공되지 않았습니다"
    echo "사용법: $0 <json_파일_경로>"
    exit 1
fi

JSON_FILE="$1"

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON 파일을 찾을 수 없습니다: $JSON_FILE"
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
        echo "JDK $version을 찾을 수 없습니다. 설치 중..."
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
            echo "Node.js $version을 찾을 수 없습니다. 설치 중..."
            nvm install "$version"
            nvm use "$version"
        fi
    else
        echo "NVM을 찾을 수 없습니다. NVM과 Node.js $version 설치 중..."
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

        echo "JDK 버전 $jdk_version 선택 또는 설치"
        select_or_install_jdk "$jdk_version"

        java -version
        ;;
    "node")
        node_version=$(parse_json '.node_version')

        if [ -z "$node_version" ]; then
            echo "Error: JSON 데이터에서 node_version을 찾을 수 없습니다"
            exit 1
        fi

        echo "Node.js 버전 $node_version 선택 또는 설치"
        select_or_install_node "$node_version"

        node --version

        # Yarn 설치
        if ! command -v yarn > /dev/null 2>&1; then
            echo "Yarn을 설치 중입니다..."
            npm install -g yarn
        fi

        yarn --version
        ;;
    "node_with_nginx")
        node_version=$(parse_json '.node_version')

        if [ -z "$node_version" ]; then
            echo "Error: JSON 데이터에서 node_version을 찾을 수 없습니다"
            exit 1
        fi

        echo "Node.js 버전 $node_version 선택 또는 설치"
        select_or_install_node "$node_version"

        node --version

        # Yarn 설치
        if ! command -v yarn > /dev/null 2>&1; then
            echo "Yarn을 설치 중입니다..."
            npm install -g yarn
        fi

        yarn --version
        ;;
    *)
        echo "지원되지 않는 builder입니다: $builder"
        exit 1
        ;;
esac

echo "런타임 설정이 성공적으로 완료되었습니다"

echo "빌드 프로세스 시작"
build_commands=$(parse_json '.build_commands[]')

build_dir=$(parse_json '.build_dir')

echo "디렉토리 이동"

if [ -z "$build_dir" ]; then
  echo "build_dir이 설정되지 않았습니다. 루트 디렉토리로 이동합니다."
  cd ./
else
  if [ "${build_dir#/}" != "$build_dir" ]; then
    build_dir=".$build_dir"
  fi
  if [ -d "$build_dir" ]; then
    cd "$build_dir"
  else
    echo "build_dir이 설정되지 않았습니다. 루트 디렉토리로 이동합니다."
    cd ./
  fi
fi

echo "실행 중: $build_commands"
eval "$build_commands"
if [ $? -ne 0 ]; then
    echo "빌드 명령이 실패했습니다: $build_commands"
    exit 1
fi

echo "빌드 프로세스가 성공적으로 완료되었습니다"
