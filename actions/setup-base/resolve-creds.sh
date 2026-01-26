#!/bin/bash
set -e

ENVIRONMENT=$1
CONFIG_FILE=$2

if [[ -z "$ENVIRONMENT" ]]; then
  echo "No environment provided. Skipping credential resolution."
  exit 0
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file $CONFIG_FILE not found."
  exit 1
fi

echo "Resolving credentials for environment: $ENVIRONMENT"

if ! type jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed."
    exit 1
fi

if ! jq -e --arg env "$ENVIRONMENT" '.gcp_account_config | has($env)' "$CONFIG_FILE" > /dev/null; then
  echo "Error: Environment '$ENVIRONMENT' not found in $CONFIG_FILE"
  exit 1
fi

WIP=$(jq -r --arg env "$ENVIRONMENT" '.gcp_account_config[$env].workload_identity_provider' "$CONFIG_FILE")
SA=$(jq -r --arg env "$ENVIRONMENT" '.gcp_account_config[$env].service_account_to_assume' "$CONFIG_FILE")
REGISTRY=$(jq -r --arg env "$ENVIRONMENT" '.gcp_account_config[$env].registry_host' "$CONFIG_FILE")

if [[ "$WIP" == "null" || -z "$WIP" ]]; then
  echo "Error: workload_identity_provider is missing for $ENVIRONMENT"
  exit 1
fi

if [[ "$SA" == "null" || -z "$SA" ]]; then
  echo "Error: service_account_to_assume is missing for $ENVIRONMENT"
  exit 1
fi

if [[ "$REGISTRY" == "null" || -z "$REGISTRY" ]]; then
  echo "Error: registry_host is missing for $ENVIRONMENT"
  exit 1
fi

echo "workload_identity_provider=$WIP" >> $GITHUB_OUTPUT
echo "service_account=$SA" >> $GITHUB_OUTPUT
echo "registry_host=$REGISTRY" >> $GITHUB_OUTPUT

echo "Successfully resolved credentials."
