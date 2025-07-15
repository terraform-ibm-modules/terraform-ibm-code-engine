#!/bin/bash
set -euo pipefail

IBMCLOUD_CONFIG_HOME=$(mktemp -d)
export IBMCLOUD_CONFIG_HOME

INPUT=$(cat)
REGION=$(echo "$INPUT" | jq -r '.REGION')
RESOURCE_GROUP_ID=$(echo "$INPUT" | jq -r '.RESOURCE_GROUP_ID')
IBMCLOUD_API_KEY=$(echo "$INPUT" | jq -r '.IBMCLOUD_API_KEY')
export IBMCLOUD_API_KEY

if [[ -z "${IBMCLOUD_API_KEY}" || "${IBMCLOUD_API_KEY}" == "null" ]]; then
  echo '{"error": "IBMCLOUD_API_KEY is required"}'
  exit 0
fi

if [[ -z "${RESOURCE_GROUP_ID}"  || "${RESOURCE_GROUP_ID}" == "null" ]]; then
  echo '{"error": "RESOURCE_GROUP_ID is required"}'
  exit 0
fi

if [[ -z "${REGION}" || "${REGION}" == "null" ]]; then
  echo '{"error": "REGION is required"}'
  exit 0
fi

if ! ibmcloud login -r "${REGION}" -g "${RESOURCE_GROUP_ID}" --quiet > /dev/null 2>&1; then
  printf '{"error": "Failed to login using: ibmcloud login -r %s -g %s"}' "$REGION" "$RESOURCE_GROUP_ID"
  exit 0
fi

# extract registry value from text "You are targeting region 'us-south', the registry is 'us.icr.io'."
registry=$(ibmcloud cr region 2>/dev/null | grep registry | sed -E "s/.*registry is '([^']+)'.*/\1/")

# Validate registry value
if [[ -z "$registry" ]]; then
  echo '{"error": "Failed to parse registry region from ibmcloud cr region"}'
  exit 0
fi

echo "{\"registry\": \"${registry}\"}"
