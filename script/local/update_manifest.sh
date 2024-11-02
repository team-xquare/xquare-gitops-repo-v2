#!/bin/bash

# 오류 발생 시 스크립트 중단
set -e

# 함수: Helm 템플릿 적용 및 manifest.yaml 업데이트
update_manifest() {
    local env=$1
    local service=$2
    local values_file="pipelines/${env}/${service}/values.yaml"
    local manifest_file="pipelines/${env}/${service}/resource/manifest.yaml"
    local temp_file=$(mktemp)

    echo "Updating manifest for ${service} in ${env} environment"

    # manifest.yaml에서 이미지 정보 추출
    local image_name=$(cat ${manifest_file} | grep 'image:' | sed 's/image://g' | sed 's/ //g')

    if [ -z "${image_name}" ]; then
        echo "Error: Could not extract image name from ${manifest_file}"
        return 1
    fi

    echo "Extracted image name: ${image_name}"

    # Helm 템플릿 적용 (이미지 이름 포함)
    helm template ${service} templates/server -f ${values_file} --set image_name=${image_name} > ${temp_file}

    # manifest.yaml 파일 업데이트
    if [ -f "${manifest_file}" ]; then
        mv ${temp_file} ${manifest_file}
        echo "Updated ${manifest_file}"
    else
        echo "Error: ${manifest_file} not found"
        rm ${temp_file}
        return 1
    fi
}

# 모든 환경(prod, stag)에 대해 반복
for env in prod stag; do
    # 각 환경의 서비스 디렉토리 목록
    services=$(ls pipelines/${env})

    # 각 서비스에 대해 반복
    for service in ${services}; do
        # values.yaml 파일과 manifest.yaml 파일이 존재하는 경우에만 처리
        if [ -f "pipelines/${env}/${service}/values.yaml" ] && [ -f "pipelines/${env}/${service}/resource/manifest.yaml" ]; then
            update_manifest ${env} ${service} || echo "Failed to update manifest for ${service} in ${env}"
        else
            echo "Skipping ${service} in ${env}: required files not found"
        fi
    done
done

echo "Manifest update process completed"