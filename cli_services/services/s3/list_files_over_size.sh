
#!/bin/bash

#!/bin/bash
#
# Script Name: s3_find_large_files.sh
#
# Description:
#   This script helps analyze file sizes in an S3 bucket.
#   It provides two modes:
#
#   1. Find all files larger than a given size (in MB).
#   2. Find the single largest file in the bucket.
#
# Requirements:
#   - AWS CLI installed and configured with proper IAM permissions
#   - jq (if you plan to extend filtering/formatting)
#
# Usage:
#   1. To find files larger than a given size:
#        ./s3_find_large_files.sh --over-size
#      The script will prompt for:
#        - S3 bucket name
#        - Minimum size in MB
#
#   2. To find the largest file in the bucket:
#        ./s3_find_large_files.sh --largest
#      The script will prompt for:
#        - S3 bucket name
#
# Example:
#   $ ./s3_find_large_files.sh --over-size
#   Enter S3 Bucket Name: my-app-bucket
#   Enter minimum file size in MB: 100
#   => Lists all files > 100 MB
#
#   $ ./s3_find_large_files.sh --largest
#   Enter S3 Bucket Name: my-app-bucket
#   => Shows the largest single file in the bucket
#
# Notes:
#   - Size is reported in bytes by AWS, displayed in a table format.
#   - Use this script to quickly identify oversized files or the
#     single largest object for cost optimization or debugging.
#

# Prompt user for S3 bucket and size
read -p "Enter S3 Bucket Name: " BUCKET_NAME
read -p "Enter minimum file size in MB: " SIZE_MB

# Convert MB to bytes
SIZE_BYTES=$((SIZE_MB * 1024 * 1024))

echo "Finding files > ${SIZE_MB}MB in bucket: $BUCKET_NAME"
echo

# List objects larger than given size
aws s3api list-objects-v2 \
  --bucket "$BUCKET_NAME" \
  --query "Contents[?Size > \`${SIZE_BYTES}\`].[Key, Size]" \
  --output table


#!/bin/bash

echo "Finding the largest file in bucket: $BUCKET_NAME"
echo

# Get the largest object (by size)
aws s3api list-objects-v2 \
  --bucket "$BUCKET_NAME" \
  --query "sort_by(Contents, &Size)[-1].[Key, Size]" \
  --output table

