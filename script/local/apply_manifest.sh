#!/bin/bash

# 스크립트의 실행 위치를 pipelines 디렉토리의 부모 디렉토리로 가정합니다.
BASE_DIR="./pipelines"

# 'prod'와 'stag' 환경을 순회합니다.
for ENV in prod stag; do
    echo "Applying manifests for $ENV environment..."

    # 각 환경 내의 모든 manifest.yaml 파일을 찾아 적용합니다.
    find "$BASE_DIR/$ENV" -name manifest.yaml | while read -r manifest; do
        echo "Applying $manifest"
        kubectl apply -f "$manifest"

        # 에러 체크
        if [ $? -ne 0 ]; then
            echo "Error applying $manifest"
            exit 1
        fi
    done
done

echo "All manifests have been applied successfully."