#!/bin/bash
set -e

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
  echo "IBMCLOUD_API_KEY is required" >&2
  exit 1
fi

if [[ -z "${RESOURCE_GROUP_ID}" ]]; then
  echo "RESOURCE_GROUP_ID is required" >&2
  exit 1
fi

if [[ -z "${CE_PROJECT_NAME}" ]]; then
  echo "CE_PROJECT_NAME is required" >&2
  exit 1
fi

if [[ -z "${REGION}" ]]; then
  echo "REGION is required" >&2
  exit 1
fi

if [[ -z "${BUILDS}" ]]; then
  echo "BUILDS is required" >&2
  exit 1
fi

ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP_ID}" --quiet

# selecet the right code engine project
ibmcloud ce project select -n "${CE_PROJECT_NAME}"

# run a build for all builds
# we check for status build to be succeeded before we finish with script.
# This is needed in a case we deploy app, which needs build_run to be finished.
for build in $BUILDS; do
    echo "Submitting build: $build"
    run_build_name=$(ibmcloud ce buildrun submit --build build-adn-11 --output json | jq -r '.name')

    echo "Waiting for build run $run_build_name to complete..."
    while true; do
        status=$(ibmcloud ce buildrun get --name "$run_build_name" --output json | jq -r '.status')
        echo "Status: $status"
        if [[ "$status" == "succeeded" ]]; then
            echo "Build $build succeeded"
            break
        elif [[ "$status" == "Failed" || "$status" == "Error" ]]; then
            echo "Build $build failed"
            exit 1
        else
            sleep 10
        fi
    done
done
