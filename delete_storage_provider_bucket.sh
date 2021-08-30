#!/usr/bin/env bash
set -e

if [ "$1" = "" ]; then
  echo "usage delete_storage_provider_bucket.sh <bucket-name>"
  exit
fi
bucket_name=$1

# check for aws cli and creds
which aws > /dev/null
aws sts get-caller-identity > /dev/null

bucket_user="${bucket_name}-user"

policy_name="${bucket_name}-access-policy"
policy_file="${policy_name}.json"

policy_arn=$(aws iam list-attached-user-policies --user-name ${bucket_user}|jq ".AttachedPolicies | .[] | select(.PolicyName==\"${policy_name}\")| .PolicyArn" -r)

aws iam detach-user-policy --user-name ${bucket_user} --policy-arn ${policy_arn}

aws iam delete-policy --policy-arn ${policy_arn}

rm ${policy_file} > /dev/null 2>$1

aws s3api delete-bucket-cors --bucket ${bucket_name}

aws s3api delete-bucket --bucket ${bucket_name}

aws iam delete-access-key --user-name ${bucket_user} --access-key-id $(aws iam list-access-keys --user-name ${bucket_user}|jq ".AccessKeyMetadata | .[] | select(.UserName==\"${bucket_user}\")| .AccessKeyId" -r)

aws iam delete-user --user-name ${bucket_user}
