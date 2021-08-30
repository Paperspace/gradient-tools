# Gradient Tools

## Scripts for s3 storage providers

## AWS s3 scripts

These scripts require
1. awscli
2. jq
3. AWS default credentials to create IAM users, policies, access keys, and s3 buckets

[create_storage_provider_bucket.sh](create_storage_provider_bucket.sh)
```
Usage: ./create_storage_provider_bucket.sh <storage-provider-bucket-name> [<aws-region>]
```

[delete_storage_provider_bucket.sh](delete_storage_provider_bucket.sh)

Note: before deleteing the bucket, you must empty it. This can be done as follows:
```
aws s3 rm s3://gradient-storage-provider-test1 --recursive
```
```
Usage: ./delete_storage_provider_bucket.sh <storage-provider-bucket-name> 
```
