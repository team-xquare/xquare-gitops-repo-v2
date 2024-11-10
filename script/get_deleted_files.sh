#!/bin/bash

git diff --name-status HEAD^ HEAD | grep '^D' | cut -f2 > deleted_files.txt
echo "Deleted files:"
cat deleted_files.txt
