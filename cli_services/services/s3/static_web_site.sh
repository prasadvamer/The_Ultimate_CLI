#!/bin/bash

# Exit on any error
set -e

# Ensure bucket name is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <s3-bucket-name>"
  exit 1
fi

BUCKET_NAME=$1
REGION="ap-northeast-1"
SOURCE_IP="153.142.38.216"

echo "Creating S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME --region $REGION

echo "Enabling static website hosting"
aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document error.html

echo "Cleaning bucket contents if any"
aws s3 rm s3://$BUCKET_NAME --recursive || true

echo "Syncing /table_definition to the bucket"
aws s3 sync /table_definition s3://$BUCKET_NAME

echo "Enabling public access"
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration '{
    "BlockPublicAcls": false,
    "IgnorePublicAcls": false,
    "BlockPublicPolicy": false,
    "RestrictPublicBuckets": false
  }'

echo "Confirming public access block settings"
aws s3api get-public-access-block --bucket $BUCKET_NAME

echo "Setting bucket policy"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
    {
      \"Sid\": \"PublicReadGetObject\",
      \"Effect\": \"Allow\",
      \"Principal\": \"*\",
      \"Action\": \"s3:GetObject\",
      \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\",
      \"Condition\": {
        \"IpAddress\": {
          \"aws:SourceIp\": \"$SOURCE_IP\"
        }
      }
    }
  ]
}"

echo ""
echo "✅ Static website is available at:"
echo "http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
