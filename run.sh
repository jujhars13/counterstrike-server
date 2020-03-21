#!/usr/bin/env bash
# spins up vpc and then ec2 instance using cloudformation
# ensure AWS_PROFILE/SECRET_ACCESS are set before

readonly FILE_DIRECTORY=$(dirname "${BASH_SOURCE[0]}")
readonly TEMPLATE="${FILE_DIRECTORY}/cloudFormation/01-network.yml"
readonly STACK_NAME="cs-server"
readonly BATCH="batch-${RANDOM}"
readonly NOW=$(date +%Y-%m-%dT%H:%M:%S)
readonly TAGS=("ApplicationName=cs-server" "Batch=${BATCH}" "DateCreation=${NOW}" "StackName=${STACK_NAME}" "Owner=Jujhar@jujhar.com")
readonly AWS_DEFAULT_REGION="eu-west-1"

# This prevents an issue with the expansion of the variable $PARAMETERS
# shellcheck disable=SC2086
aws cloudformation deploy \
  --template-file "${TEMPLATE}" \
  --stack-name "${STACK_NAME}" \
  --capabilities CAPABILITY_IAM \
  --tags "${TAGS[@]}" \
  --no-fail-on-empty-changeset \
  --parameter-overrides ${PARAMETERS} \
  --region "${AWS_DEFAULT_REGION}"
