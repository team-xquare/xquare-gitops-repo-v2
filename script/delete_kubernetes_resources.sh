#!/bin/bash

# 변경된 파일을 가져옴
echo "Fetching the list of deleted files..."
git diff --name-status HEAD^ HEAD | grep '^D' | cut -f2 > deleted_files.txt

echo "List of deleted files:"
cat deleted_files.txt

# 삭제된 파일 내용을 기반으로 리소스 삭제
echo "Deleting Kubernetes resources..."
cat deleted_files.txt | grep '/resource/manifest.yaml$' | while read -r file; do
  echo "Attempting to delete resource from: $file"
  
  # Git에서 삭제된 파일 내용을 추출하여 삭제 처리
  git show HEAD^:"$file" | kubectl delete -f - \
  && echo "Successfully deleted: $file" \
  || echo "Failed to delete: $

echo "All deletion tasks have been completed."
