#!/usr/bin/env bash
set -e

if [ "$1" = "" ]; then
  echo "usage create_storage_provider_bucket.sh <bucket-name> [<aws-region>]"
  exit
fi
bucket_name=$1

aws_region="us-east-1"
if [ "$2" != "" ]; then
  aws_region="$2"
fi

# check for aws cli and creds
which aws > /dev/null
aws sts get-caller-identity > /dev/null

bucket_user="${bucket_name}-user"
echo "Creating user ${bucket_user}"
aws iam create-user --user-name ${bucket_user}
echo

echo "Creating access key for user ${bucket_user}"
aws iam create-access-key --user-name ${bucket_user}
echo

echo "Creating bucket ${bucket_name}"
aws s3api create-bucket --bucket "${bucket_name}" --region us-east-1 
echo

echo "Assigning CORS rules to bucket ${bucket_name}"
aws s3api put-bucket-cors --bucket "${bucket_name}" --cors-configuration '{
  "CORSRules": [
    {
      "AllowedHeaders": ["*"],
      "AllowedMethods": ["GET", "PUT"],
      "AllowedOrigins": ["https://console.paperspace.com"],
      "MaxAgeSeconds": 3000
    }
  ]
}'
aws s3api get-bucket-cors --bucket ${bucket_name}
echo

policy_name="${bucket_name}-access-policy"
policy_file="${policy_name}.json"
sed -e "s/XXXXX-BUCKET-NAME-XXXXX/${bucket_name}/" > ${policy_file} <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGeneratedUrls",
            "Effect": "Allow",
            "Action": "sts:GetFederationToken",
            "Resource": "*"
        },
        {
            "Sid": "AllowListBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::XXXXX-BUCKET-NAME-XXXXX"
        },
        {
            "Sid": "AllowBucketAccess",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::XXXXX-BUCKET-NAME-XXXXX/*"
        }
    ]
}
EOF

echo "Creating policy ${policy_name} from file ${policy_file}"
cat ${policy_file}
echo

policy_arn=$(aws iam create-policy --policy-name ${policy_name} --policy-document file://${policy_file}|grep '"Arn":'|awk '{print $2}'|sed -e 's/,$//' -e 's/^"//' -e 's/"$//')
echo "Attaching policy ${policy_arn} to user ${bucket_user}"
aws iam attach-user-policy --user-name ${bucket_user} --policy-arn ${policy_arn}
echo
