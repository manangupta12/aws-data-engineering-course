#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="${1:-day50-etl-demo}"
REGION="${2:-${AWS_REGION:-us-east-1}}"

echo "Deleting CloudFormation stack ${STACK_NAME} in ${REGION}..."
aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"

echo "Stack deleted."

PROJECT_PREFIX="${3:-}"
if [[ -n "$PROJECT_PREFIX" ]]; then
  ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
  ARTIFACT_BUCKET="${PROJECT_PREFIX}-cfn-artifacts-${ACCOUNT_ID}"
  echo ""
  echo "Optional: remove artifact bucket (must be empty first):"
  echo "aws s3 rm s3://${ARTIFACT_BUCKET} --recursive --region ${REGION}"
  echo "aws s3 rb s3://${ARTIFACT_BUCKET} --region ${REGION}"
fi
