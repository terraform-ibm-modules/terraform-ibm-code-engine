#!/bin/bash
set -e

# max wait time = 60 × 10s = 10 minutes
MAX_RETRIES=60
RETRY_INTERVAL=10  # seconds

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

if [[ -z "${BUILD_NAME}" ]]; then
  echo "BUILD_NAME is required" >&2
  exit 1
fi

ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP_ID}" --quiet

# selecet the right code engine project
ibmcloud ce project select -n "${CE_PROJECT_NAME}"

# check the image build status
image_build_status=$(ibmcloud ce build get --name "${BUILD_NAME}" -o json | jq -r '.status')
if [[ "$image_build_status" != "ready" ]]; then
  echo "Error: Image build '${BUILD_NAME}' has status: ${image_build_status}"
  exit 1
fi

# Ensure the build status is 'succeeded' before continuing.
# This is required because the application deployment depends on a completed build run.
echo "Submitting build: $BUILD_NAME"
run_build_name=$(ibmcloud ce buildrun submit --build "$BUILD_NAME" --output json | jq -r '.name')

echo "Waiting for build run $run_build_name to complete..."
retries=0

while true; do
    ibmcloud target -r "${REGION}" -g "${RESOURCE_GROUP_ID}" 
    status=$(ibmcloud ce buildrun get --name "$run_build_name" --output json | jq -r '.status')
    echo "Status: $status"
    if [[ "$status" == "succeeded" ]]; then
        echo "Build $BUILD_NAME succeeded"
        break
    elif [[ "$status" == "Failed" || "$status" == "Error" ]]; then
        echo "Error: Build $BUILD_NAME has status '{$status}'"
        exit 1
    fi

    #  if max time timeout then finish with error
    if [[ $retries -ge $MAX_RETRIES ]]; then
        echo "Build $BUILD_NAME did not complete after $MAX_RETRIES retries. Timing out."
        exit 1
    fi

    retries=$((retries + 1))
    sleep "$RETRY_INTERVAL"
done
