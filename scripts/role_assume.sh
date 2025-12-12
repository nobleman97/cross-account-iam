#!/bin/bash
ROLE_ARN="arn:aws:iam::<target-account-id>:role/access-s3-bucket"
BUCKET="iss-reporting-24534576df"

echo "Assuming role..."
CREDS=$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "TestS3Access")

export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

echo "Testing S3 access..."
if aws s3 ls "s3://$BUCKET" >/dev/null 2>&1; then
  echo "✅ SUCCESS: Access to $BUCKET confirmed!"
else
  echo "❌ FAILED: No access to $BUCKET"
fi