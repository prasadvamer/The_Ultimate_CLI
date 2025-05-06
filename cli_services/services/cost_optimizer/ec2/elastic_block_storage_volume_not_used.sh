#!/bin/bash

# Script to retrieve unallocated Elastic IPs for all AWS regions
echo "Retrieving available (not in use) EBS volumes for all regions"

# Get the list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Iterate through each region
for region in $regions; do
  echo "Fetching available (not in use) EBS volumes in Region: $region"

  aws ec2 describe-volumes \
    --region "$region" \
    --filters Name=status,Values=available \
    --query "Volumes[*].{ID:VolumeId,Size:Size,AZ:AvailabilityZone,Type:VolumeType,CreatedAt:CreateTime}" \
    --output table

  echo "------------------------------------------------------"
done
