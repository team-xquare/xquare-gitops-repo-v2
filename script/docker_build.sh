#!/bin/bash

set -e

ENVIRONMENT=$1
SERVICE_NAME=$2
TEMPLATE_JSON=$3

echo "$TEMPLATE_JSON"

BUILD_DIR=$(echo "$TEMPLATE_JSON" | jq -r '.build_dir // "/"')

if [[ "$BUILD_DIR" == /* ]]; then
    BUILD_DIR="./${BUILD_DIR#/}"
fi

if [[ "$BUILD_DIR" != "." && "$BUILD_DIR" != "./" ]]; then
    cp ./Dockerfile ${BUILD_DIR}
fi

ORIGINAL_DIR=$(pwd)

cd "$BUILD_DIR" || { echo "디렉토리 이동 실패: $BUILD_DIR"; exit 1; }

echo "디렉토리 : "
pwd

REPO_NAME=${SERVICE_NAME}-${ENVIRONMENT}
RANDOM_TAG=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
IMAGE_TAG="${ENVIRONMENT}-${RANDOM_TAG}"
IMAGE_REGISTRY="786584124104.dkr.ecr.ap-northeast-2.amazonaws.com"

# ECR 저장소가 존재하는지 확인
REPO_EXISTS=$(aws ecr describe-repositories --repository-names "${REPO_NAME}" --region ap-northeast-2 2>&1 || echo "RepositoryNotFoundException")

if [[ ${REPO_EXISTS} == *"RepositoryNotFoundException"* ]]; then
  echo "저장소 ${REPO_NAME}가 존재하지 않습니다. 지금 생성합니다..."
  aws ecr create-repository --repository-name "${REPO_NAME}" --region ap-northeast-2
else
  echo "저장소 ${REPO_NAME}가 이미 존재합니다."
fi

ls

BUILDER_=$(echo "$TEMPLATE_JSON" | jq -r '.builder // "/"')

echo "builder : $BUILDER"

if [[ "$BUILDER" == "gradle" ]]
then
    chmod +x gradlew
fi

docker system prune -f

docker buildx build -t "${IMAGE_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}" .

# AWS ECR에 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${IMAGE_REGISTRY}

# Docker 이미지를 ECR 저장소에 푸시
docker push "${IMAGE_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}"

cd "$ORIGINAL_DIR" || { echo "디렉토리 이동 실패: $ORIGINAL_DIR"; exit 1; }

# 환경 변수 파일에 저장소 URI 저장
VARIABLE_NAME=$(echo ${SERVICE_NAME}_REPOSITORY | tr '-' '_')
echo "export ${VARIABLE_NAME}=${IMAGE_REGISTRY}/${REPO_NAME}:${IMAGE_TAG}" > build_result.env
