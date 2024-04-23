#!/bin/bash

# Note: Make sure that you set the AWS_PROFILE environment variable to "audit" before running the script

# Get the GuardDuty detector ID
DETECTOR_ID=$(aws guardduty list-detectors --query DetectorIds[0] --output text)

# Disable auto-enable organization members
aws guardduty update-organization-configuration --detector-id $DETECTOR_ID --auto-enable-organization-member NONE

# Loop through each member account and disable GuardDuty
MEMBER_ACCOUNTS=$(aws guardduty list-members --detector-id $DETECTOR_ID --query Members[*].AccountId --output text)
for MEMBER_ACCOUNT in $MEMBER_ACCOUNTS
do
  echo "Suspending GuardDuty for account $MEMBER_ACCOUNT"
  aws guardduty stop-monitoring-members --account-ids $MEMBER_ACCOUNT --detector-id $DETECTOR_ID
done