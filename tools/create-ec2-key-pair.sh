#!/usr/bin/env bash

set -o errexit
set -o pipefail

err() {
  echo "${1}" 1>&2
  echo "Exiting."
  exit 1
}

KEY_DIR="$PWD/ssh-keys"
[[ -d $KEY_DIR ]] || err "Cannot access '${KEY_DIR}'."

echo -n "Retrieving AWS user information..."
if user_name=$(aws iam get-user --query 'User.UserName' --output text); then
  echo "ok."
else
  err "failed."
fi
KEY_NAME=${user_name%%@*}

echo -n "Checking for existing EC2 key pairs..."
if keycount=$(aws ec2 describe-key-pairs \
    --filters Name=key-name,Values="$KEY_NAME" --query 'length(KeyPairs)' \
    --output text 2>/dev/null); then
  if (($keycount == 0)); then
    echo "ok."
  else
    err "key '${KEY_NAME}' already exists."
  fi
else
  err "failed."
fi

KEY_FILE="$KEY_DIR/ec2-key.pem"
echo -n "Creating EC2 key pair '${KEY_NAME}'..."
if aws ec2 create-key-pair --key-name $KEY_NAME --output json 2>/dev/null |
    jq -r '.KeyMaterial' > $KEY_FILE && chmod 0600 $KEY_FILE; then
  echo "ok."
else
  err "failed."
fi

echo "Wrote private key to '${KEY_FILE##$PWD/}'. Have a nice day!"
