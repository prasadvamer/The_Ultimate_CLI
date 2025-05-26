#!/bin/bash

echo "Retrieving VPC Endpoints in all AWS regions..."

# Get list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Iterate through each region and list VPC endpoints
for region in $regions; do
  echo "----- Region: $region -----"
  aws ec2 describe-vpc-endpoints \
    --region "$region" \
    --query "VpcEndpoints[].{ID:VpcEndpointId,Service:ServiceName,State:State,Type:VpcEndpointType,Created:CreationTimestamp}" \
    --output table
done
