#!/bin/bash

# 오류 발생 시 스크립트 중단
set -e

# 기본 디렉토리 설정
BASE_DIR="./pipelines"

# 변경된 values.yaml 파일 찾기
changed_files=$(git diff --name-only HEAD HEAD~1 | grep 'values.yaml$' || true)

if [ -z "$changed_files" ]; then
    echo "No values.yaml files were changed"
    exit 0
fi

# 'prod'와 'stag' 환경에 대해 반복
for file in $changed_files; do
    ENV=$(echo $file | cut -d'/' -f2)
    SERVICE=$(echo $file | cut -d'/' -f3)
    MANIFEST_FILE="${BASE_DIR}/${ENV}/${SERVICE}/resource/manifest.yaml"

    echo "Processing ${SERVICE} in ${ENV} environment..."

    # manifest.yaml 존재 확인
    if [ ! -f "${MANIFEST_FILE}" ]; then
        echo "Warning: ${MANIFEST_FILE} not found, skipping..."
        continue
    fi

    # manifest.yaml에서 현재 이미지 정보 추출
    IMAGE_NAME=$(grep -o 'image:.*' "${MANIFEST_FILE}" | sed 's/image://g' | tr -d ' ')
    
    if [ -z "${IMAGE_NAME}" ]; then
        echo "Error: Could not extract image name from ${MANIFEST_FILE}"
        continue
    fi

    echo "Current image: ${IMAGE_NAME}"

    # Helm 템플릿 적용
    if ! helm template ${SERVICE} templates/server \
        -f "${file}" \
        --set image_name="${IMAGE_NAME}" > "${MANIFEST_FILE}"; then
        echo "Error: Failed to update manifest for ${SERVICE}"
        continue
    fi

    echo "Successfully updated ${MANIFEST_FILE}"
done

echo "Manifest update process completed"
