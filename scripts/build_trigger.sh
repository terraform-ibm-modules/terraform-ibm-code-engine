#!/bin/bash

set -euo pipefail

REGION="$1"
PROJECT_ID="$2"
BUILD_NAME="$3"

if [[ -z "${REGION}" ]]; then
    echo "Region must be passed as first input script argument" >&2
    exit 1
fi

if [[ -z "${PROJECT_ID}" ]]; then
    echo "Project_id must be passed as second input script argument" >&2
    exit 1
fi

if [[ -z "${BUILD_NAME}" ]]; then
    echo "Build_name must be passed as third input script argument" >&2
    exit 1
fi

URL="https://api.$REGION.codeengine.cloud.ibm.com/v2/projects/$PROJECT_ID/build_runs"
response=$(curl -s "$URL" --header "Authorization: $IAM_TOKEN" --header "Content-Type: application/json" -X POST -d "{ \"build_name\" : \"$BUILD_NAME\"}")

build_id=$(echo "$response" | jq -r '.name')

STATUS_URL="https://api.$REGION.codeengine.cloud.ibm.com/v2/projects/$PROJECT_ID/build_runs/$build_id"

# while true; do
attempts=1
until [ $attempts -ge 20 ]; do
    attempts=$((attempts + 1))
    response=$(curl -s "$STATUS_URL" --header "Authorization: $IAM_TOKEN")
    status=$(echo "$response" | jq -r '.status')
    if [[ "$status" == "succeeded" ]]; then
        echo "Image created."
        break
    elif [[ "$status" == "running" || "$status" == "pending" ]]; then
        echo "Running..."
    else
        echo "Image build failed. Make sure the namespace exists."
        break
    fi
    sleep 30
    status=""
done
