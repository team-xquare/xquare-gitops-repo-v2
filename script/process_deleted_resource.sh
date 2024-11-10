#!/bin/bash

echo "Processing deleted Kubernetes manifests..."

cat deleted_files.txt | grep '/resource/manifest.yaml$' | xargs -P 4 -I {} sh -c '
  echo "Attempting to delete resource defined in: {}"
  kubectl delete -f "{}" && echo "Successfully deleted resource from: {}" || echo "Failed to delete resource from: {}"
'