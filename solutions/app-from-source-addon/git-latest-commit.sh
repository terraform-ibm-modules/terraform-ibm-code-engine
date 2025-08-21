#!/bin/bash
set -e
CLONE_DIR=$(mktemp -d -t repo-XXXXXXXX)
git clone --depth 1 https://github.com/IBM/CodeEngine.git "$CLONE_DIR"
cd "$CLONE_DIR"
hash=$(git rev-parse HEAD)
FOLDER_HASH=$(find "hello" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')

echo "{\"hash\": \"$FOLDER_HASH\"}"