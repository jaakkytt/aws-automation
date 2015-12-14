#!/bin/bash

set -o errexit
set -o pipefail

err() {
  echo "${1}" 1>&2
  echo "Exiting."
  exit 1
}

usage() {
  err "usage: ${0##*/} -k key_name -i image_id"
}

unset KEY_NAME
unset IMAGE_ID
while getopts "k:i:" opt; do
  case $opt in
    k)  KEY_NAME=$OPTARG;;
    i)  IMAGE_ID=$OPTARG;;
    *)  usage;;
  esac
done
shift $((OPTIND-1))
(($# == 0)) || usage
[[ -n "${IMAGE_ID}" && -n "${KEY_NAME}" ]] || usage

read -r -d '#' RUN_PARAMS <<EOT
{
  "ImageId": "$IMAGE_ID",
  "KeyName": "$KEY_NAME",
  "SecurityGroups": [
    "Lab-Security-Group"
  ],
  "InstanceType": "t2.micro"
}
#
EOT

echo -n "Launching EC2 instance..."
if instance_id=$(aws ec2 run-instances --cli-input-json "$RUN_PARAMS" \
  --output text --query 'Instances[0].InstanceId' 2>/dev/null); then
  echo "ok. Got instance ID: ${instance_id}."
else
  err "failed."
fi

echo -n "Waiting for instance to boot..."
if aws ec2 wait instance-running --instance-ids $instance_id 2>/dev/null; then
  echo "done."
else
  err "failed."
fi

echo -n "Creating project tags..."
if aws ec2 create-tags --resources ${instance_id} \
    --tags 'Key=b4nk:project,Value=aws-automation' 2>/dev/null; then
  echo "ok."
else
  err "failed."
fi

echo -n "Retrieving instance information..."
if dnsname=$(aws ec2 describe-instances --instance-ids $instance_id --output \
    text --query 'Reservations[].Instances[].PublicDnsName' 2>/dev/null); then
  echo "ok."
else
  err "failed."
fi

echo "Instance public DNS: ${dnsname}"
