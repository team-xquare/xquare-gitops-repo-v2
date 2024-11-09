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

# 변경된 values.yaml에 해당하는 manifest 적용
for file in $changed_files; do
    ENV=$(echo $file | cut -d'/' -f2)
    SERVICE=$(echo $file | cut -d'/' -f3)
    MANIFEST_FILE="${BASE_DIR}/${ENV}/${SERVICE}/resource/manifest.yaml"

    echo "Applying manifest for ${SERVICE} in ${ENV} environment..."

    # manifest.yaml 존재 확인
    if [ ! -f "${MANIFEST_FILE}" ]; then
        echo "Warning: ${MANIFEST_FILE} not found, skipping..."
        continue
    fi

    # 매니페스트 적용
    if ! kubectl apply -f "${MANIFEST_FILE}"; then
        echo "Error applying ${MANIFEST_FILE}"
        exit 1
    fi

    echo "Successfully applied ${MANIFEST_FILE}"
done

echo "All manifests have been applied successfully"