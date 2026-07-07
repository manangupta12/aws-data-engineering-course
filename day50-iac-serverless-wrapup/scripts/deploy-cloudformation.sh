#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <project-prefix> [stack-name] [aws-region]"
  echo "Example: $0 jane-de-2026 day50-etl-demo us-east-1"
  exit 1
}

PROJECT_PREFIX="${1:-}"
STACK_NAME="${2:-day50-etl-demo}"
REGION="${3:-${AWS_REGION:-us-east-1}}"

if [[ -z "$PROJECT_PREFIX" ]]; then
  usage
fi

if [[ ! "$PROJECT_PREFIX" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: project prefix must be lowercase letters, numbers, and hyphens only."
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ARTIFACT_BUCKET="${PROJECT_PREFIX}-cfn-artifacts-${ACCOUNT_ID}"
ARTIFACT_KEY="lambda/etl-orders/function.zip"
TEMPLATE_FILE="infra/cloudformation/etl-stack.yaml"

echo "Packaging Lambda code..."
rm -f function.zip
(cd lambda/etl_orders && zip -r ../../function.zip .)

echo "Ensuring artifact bucket s3://${ARTIFACT_BUCKET} exists..."
if ! aws s3api head-bucket --bucket "$ARTIFACT_BUCKET" --region "$REGION" 2>/dev/null; then
  aws s3 mb "s3://${ARTIFACT_BUCKET}" --region "$REGION"
fi

echo "Uploading Lambda artifact..."
aws s3 cp function.zip "s3://${ARTIFACT_BUCKET}/${ARTIFACT_KEY}" --region "$REGION"

echo "Validating CloudFormation template..."
aws cloudformation validate-template \
  --template-body "file://${TEMPLATE_FILE}" \
  --region "$REGION" >/dev/null

echo "Deploying stack ${STACK_NAME}..."
aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
    "ProjectPrefix=${PROJECT_PREFIX}" \
    "LambdaArtifactBucket=${ARTIFACT_BUCKET}" \
    "LambdaArtifactKey=${ARTIFACT_KEY}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$REGION" \
  --no-fail-on-empty-changeset

RAW_BUCKET="${PROJECT_PREFIX}-orders-raw"
LAMBDA_ARN="$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='LambdaFunctionArn'].OutputValue" \
  --output text)"

echo "Configuring S3 event notification on ${RAW_BUCKET}..."
NOTIFICATION_FILE="$(mktemp)"
cat > "$NOTIFICATION_FILE" <<EOF
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "IncomingCsvTrigger",
      "LambdaFunctionArn": "${LAMBDA_ARN}",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {"Name": "prefix", "Value": "incoming/"},
            {"Name": "suffix", "Value": ".csv"}
          ]
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-notification-configuration \
  --bucket "$RAW_BUCKET" \
  --notification-configuration "file://${NOTIFICATION_FILE}" \
  --region "$REGION"
rm -f "$NOTIFICATION_FILE"

echo ""
echo "Stack deployed. Outputs:"
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs" \
  --output table

RAW_BUCKET="$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='RawBucketName'].OutputValue" \
  --output text)"

echo ""
echo "Upload sample data to trigger ETL:"
echo "aws s3 cp data/orders.csv s3://${RAW_BUCKET}/incoming/orders.csv --region ${REGION}"
