#!/usr/bin/env bash
# spins up vpc and then ec2 instance using cloudformation
# ensure AWS_PROFILE/SECRET_ACCESS are set before

readonly FILE_DIRECTORY=$(dirname "${BASH_SOURCE[0]}")
readonly STACK_NAME="cs-gaming-${RANDOM}"
readonly BATCH="batch-${RANDOM}"
readonly NOW=$(date +%Y-%m-%dT%H:%M:%S)
readonly TAGS=("ApplicationName=cs-server" "Batch=${BATCH}" "DateCreation=${NOW}" "StackName=${STACK_NAME}" "Owner=jujhar@jujhar.com")
readonly AWS_DEFAULT_REGION="eu-west-2"
readonly UserDataScript="$(< ${FILE_DIRECTORY}/cloudFormation/ec2-user-data.sh)"
readonly myIpAddress="$(curl -s https://ifconfig.me/)/32"

echo "Deploying network ${STACK_NAME}"
# deploy network
aws cloudformation deploy \
  --template-file "${FILE_DIRECTORY}/cloudFormation/01-networking.yml" \
  --stack-name "${STACK_NAME}-net" \
  --capabilities CAPABILITY_IAM \
  --tags "${TAGS[@]}" \
  --no-fail-on-empty-changeset \
  --region "${AWS_DEFAULT_REGION}" \
  --parameter-overrides \
      stackName="${STACK_NAME}" \
# have to wait for VPC  
aws cloudformation wait \
stack-exists \
--stack-name "${STACK_NAME}-net"

echo "Finding the current Amazon Linuz 2 AMI"
readonly LINUX2_AMI=$(aws ec2 describe-images \
  --owners amazon \
  --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' 'Name=state,Values=available' \
  --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' \
  --output text)
echo "This is the current Linux 2 AMI: ${LINUX2_AMI}"


echo "Deploying server ${STACK_NAME}"

# deploys server
aws cloudformation deploy \
  --template-file "${FILE_DIRECTORY}/cloudFormation/02-server.yml" \
  --stack-name "${STACK_NAME}-svr" \
  --capabilities CAPABILITY_IAM \
  --tags "${TAGS[@]}" \
  --no-fail-on-empty-changeset \
  --region "${AWS_DEFAULT_REGION}" \
  --parameter-overrides \
      stackName="${STACK_NAME}" \
      Linux2Ami="${LINUX2_AMI}" \
      UserDataScript="${UserDataScript}" \
      myIpAddress="${myIpAddress}"
