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
for build in $BUILDS; do
    echo "$build"
    ibmcloud ce buildrun submit --build  "$build"
done
