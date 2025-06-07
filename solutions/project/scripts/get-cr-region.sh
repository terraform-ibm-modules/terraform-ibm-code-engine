#!/bin/bash
set -e

INPUT=$(cat)
REGION=$(echo "$INPUT" | jq -r '.REGION')
RESOURCE_GROUP_ID=$(echo "$INPUT" | jq -r '.RESOURCE_GROUP_ID')
IBMCLOUD_API_KEY=$(echo "$INPUT" | jq -r '.IBMCLOUD_API_KEY')

if [[ -z "${IBMCLOUD_API_KEY}" || "${IBMCLOUD_API_KEY}" == "null" ]]; then
  echo "IBMCLOUD_API_KEY is required" >&2
  exit 1
fi

if [[ -z "${RESOURCE_GROUP_ID}"  || "${RESOURCE_GROUP_ID}" == "null" ]]; then
  echo "RESOURCE_GROUP_ID is required" >&2
  exit 1
fi

if [[ -z "${REGION}" || "${REGION}" == "null" ]]; then
  echo "REGION is required" >&2
  exit 1
fi

# Login to IBM Cloud quietly
if ! ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP_ID}" --apikey "${IBMCLOUD_API_KEY}" --quiet > /dev/null 2>&1; then
  exit 1
fi

# extract registry value from text "You are targeting region 'us-south', the registry is 'us.icr.io'."
registry=$(ibmcloud cr region 2>/dev/null | grep registry | sed -E "s/.*registry is '([^']+)'.*/\1/") || exit 1

# Output valid JSON for Terraform external data source
echo "{\"registry\": \"${registry}\"}"
