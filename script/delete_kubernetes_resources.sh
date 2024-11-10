#!/bin/bash

# 변경된 파일을 가져옴
echo "Fetching the list of deleted files..."
git diff --name-status HEAD^ HEAD | grep '^D' | cut -f2 > deleted_files.txt

echo "List of deleted files:"
cat deleted_files.txt

# 삭제된 파일을 찾아서 리소스 삭제
echo "Deleting Kubernetes resources..."
cat deleted_files.txt | grep '/resource/manifest.yaml$' | xargs -P 4 -I {} sh -c '
  echo "Attempting to delete resource: {}"
  kubectl delete -f "{}" && echo "Successfully deleted: {}" || echo "Failed to delete: {}"
'

echo "All deletion tasks have been completed."
