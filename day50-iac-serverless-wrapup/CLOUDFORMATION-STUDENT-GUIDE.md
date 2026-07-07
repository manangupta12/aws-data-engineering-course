# CloudFormation Student Guide

**Follow this guide step by step** to deploy the Day 50 ETL stack with AWS CloudFormation.

**Project:** `day50-iac-serverless-wrapup/`  
**Time:** ~25 minutes  
**Cost:** S3 + Lambda + Secrets Manager fit free tier for lab use.

> **Terraform alternative:** [IAC-STUDENT-GUIDE.md](IAC-STUDENT-GUIDE.md)

---

## What you are building

Same architecture as the Terraform lab:

| Resource | CloudFormation type | Purpose |
|----------|---------------------|---------|
| Raw S3 bucket | `AWS::S3::Bucket` | Upload CSV under `incoming/` |
| Processed S3 bucket | `AWS::S3::Bucket` | Store transformed JSON |
| Secrets Manager secret | `AWS::SecretsManager::Secret` | Secure DB credentials |
| Lambda function | `AWS::Lambda::Function` | Serverless ETL |
| IAM role | `AWS::IAM::Role` | Least-privilege Lambda permissions |
| CloudWatch log group | `AWS::Logs::LogGroup` | Lambda logs (7-day retention) |
| S3 → Lambda trigger | CLI step after deploy | Runs ETL on `.csv` upload |

**Template file:** `infra/cloudformation/etl-stack.yaml`  
**Deploy script:** `scripts/deploy-cloudformation.sh`

---

## Before you start — checklist

| Item | Your value |
|------|------------|
| AWS account ID | `________________` |
| AWS region | `________________` (e.g. `us-east-1`) |
| Unique prefix (lowercase) | `________________` (e.g. `jane-de-2026`) |
| AWS CLI works? | `aws sts get-caller-identity` ☐ |
| `zip` installed? | `zip --version` ☐ |

### Install AWS CLI

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

```bash
aws configure
aws sts get-caller-identity
```

### Clone the repo

```bash
git clone https://github.com/manangupta12/aws-data-engineering-course.git
cd aws-data-engineering-course/day50-iac-serverless-wrapup
```

---

## Part 1: Understand the template (5 min)

Open `infra/cloudformation/etl-stack.yaml` and scan these sections:

| Section | What it does |
|---------|--------------|
| `Parameters` | Inputs you pass at deploy time |
| `Resources` | AWS objects to create |
| `Outputs` | Values to copy after deploy |

### Parameters

| Parameter | Description |
|-----------|-------------|
| `ProjectPrefix` | Unique prefix for bucket and function names |
| `LambdaArtifactBucket` | S3 bucket holding the Lambda zip |
| `LambdaArtifactKey` | Path to zip inside artifact bucket |
| `DefaultS3Key` | Default CSV path inside raw bucket |

### Resources created

```
ProjectPrefix-orders-raw          ← S3 raw bucket
ProjectPrefix-orders-processed    ← S3 processed bucket
ProjectPrefix/rds/orders-db       ← Secrets Manager secret
ProjectPrefix-etl-lambda-role     ← IAM role
ProjectPrefix-etl-orders          ← Lambda function
/aws/lambda/ProjectPrefix-etl-orders ← Log group
```

### Why CloudFormation needs a Lambda zip in S3

Unlike Terraform (which zips local files during `apply`), CloudFormation deploys Lambda code from:

- inline `ZipFile` (tiny placeholder only), or
- **S3 bucket + key** (production pattern)

Our deploy script packages `lambda/etl_orders/`, uploads to S3, then passes bucket/key to the stack.

---

## Part 2: Run local tests first (5 min)

No AWS charges — validates Python before deploy:

```bash
chmod +x scripts/local-test.sh
./scripts/local-test.sh
```

**Expected:** flake8 + pytest pass.

---

## Part 3: Deploy with one command (10 min)

```bash
chmod +x scripts/deploy-cloudformation.sh
./scripts/deploy-cloudformation.sh YOUR-UNIQUE-PREFIX
```

Example:

```bash
./scripts/deploy-cloudformation.sh jane-de-2026 day50-etl-demo us-east-1
```

### What the script does

1. Zips `lambda/etl_orders/` → `function.zip`
2. Creates artifact bucket `{prefix}-cfn-artifacts-{account-id}` (if missing)
3. Uploads zip to S3
4. Validates template with `aws cloudformation validate-template`
5. Runs `aws cloudformation deploy`
6. Configures S3 event notification (CSV upload → Lambda)

**Expected:** Table of stack outputs at the end.

---

## Part 4: Manual deploy (optional — learn the commands)

Use this if you want to run each step yourself instead of the script.

### Step 1 — Package Lambda

```bash
cd day50-iac-serverless-wrapup
rm -f function.zip
cd lambda/etl_orders && zip -r ../../function.zip . && cd ../..
```

### Step 2 — Create artifact bucket and upload zip

```bash
export AWS_REGION=us-east-1
export PROJECT_PREFIX=jane-de-2026
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ARTIFACT_BUCKET="${PROJECT_PREFIX}-cfn-artifacts-${ACCOUNT_ID}"
export ARTIFACT_KEY="lambda/etl-orders/function.zip"

aws s3 mb "s3://${ARTIFACT_BUCKET}" --region "$AWS_REGION" 2>/dev/null || true
aws s3 cp function.zip "s3://${ARTIFACT_BUCKET}/${ARTIFACT_KEY}" --region "$AWS_REGION"
```

### Step 3 — Validate template

```bash
aws cloudformation validate-template \
  --template-body file://infra/cloudformation/etl-stack.yaml \
  --region "$AWS_REGION"
```

### Step 4 — Deploy stack

```bash
aws cloudformation deploy \
  --template-file infra/cloudformation/etl-stack.yaml \
  --stack-name day50-etl-demo \
  --parameter-overrides \
    ProjectPrefix="$PROJECT_PREFIX" \
    LambdaArtifactBucket="$ARTIFACT_BUCKET" \
    LambdaArtifactKey="$ARTIFACT_KEY" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION"
```

### Step 5 — Read outputs

```bash
aws cloudformation describe-stacks \
  --stack-name day50-etl-demo \
  --region "$AWS_REGION" \
  --query "Stacks[0].Outputs" \
  --output table
```

Save:

- `RawBucketName`
- `ProcessedBucketName`
- `LambdaFunctionName`
- `DbSecretArn`

### Step 6 — Configure S3 trigger (if not using deploy script)

CloudFormation creates the bucket and Lambda separately. The deploy script adds the S3 notification after both exist (avoids a circular dependency in the template).

If you deployed manually, re-run `./scripts/deploy-cloudformation.sh` (it is safe to re-run) or configure notification in the S3 console: **Properties → Event notifications → Lambda function → prefix `incoming/` suffix `.csv`**.

---

## Part 5: Test the ETL pipeline (5 min)

```bash
RAW_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name day50-etl-demo \
  --query "Stacks[0].Outputs[?OutputKey=='RawBucketName'].OutputValue" \
  --output text)

aws s3 cp data/orders.csv "s3://${RAW_BUCKET}/incoming/orders.csv"
```

Wait ~10 seconds, then list processed files:

```bash
PROCESSED_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name day50-etl-demo \
  --query "Stacks[0].Outputs[?OutputKey=='ProcessedBucketName'].OutputValue" \
  --output text)

aws s3 ls "s3://${PROCESSED_BUCKET}/processed/" --recursive
```

Download JSON output:

```bash
KEY=$(aws s3 ls "s3://${PROCESSED_BUCKET}/processed/" --recursive | awk '{print $4}' | head -1)
aws s3 cp "s3://${PROCESSED_BUCKET}/${KEY}" -
```

**Expected:** JSON array with normalized `amount`, `currency`, and `order_date`.

---

## Part 6: Verify Secrets Manager (3 min)

```bash
SECRET_ARN=$(aws cloudformation describe-stacks \
  --stack-name day50-etl-demo \
  --query "Stacks[0].Outputs[?OutputKey=='DbSecretArn'].OutputValue" \
  --output text)

aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --query SecretString \
  --output text | python3 -m json.tool
```

Password is generated by CloudFormation — never stored in Git.

---

## Part 7: View Lambda logs (optional)

```bash
FUNC=$(aws cloudformation describe-stacks \
  --stack-name day50-etl-demo \
  --query "Stacks[0].Outputs[?OutputKey=='LambdaFunctionName'].OutputValue" \
  --output text)

aws logs tail "/aws/lambda/${FUNC}" --since 10m --follow
```

Press `Ctrl+C` to stop.

---

## Part 8: Update the stack after code changes

1. Edit Python in `lambda/etl_orders/`
2. Re-run deploy script:

```bash
./scripts/deploy-cloudformation.sh jane-de-2026 day50-etl-demo us-east-1
```

CloudFormation updates the Lambda function when the S3 artifact changes.

---

## Part 9: Clean up (avoid charges)

```bash
chmod +x scripts/destroy-cloudformation.sh
./scripts/destroy-cloudformation.sh day50-etl-demo us-east-1 jane-de-2026
```

Then empty and delete the artifact bucket (if you want full cleanup):

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ARTIFACT_BUCKET="jane-de-2026-cfn-artifacts-${ACCOUNT_ID}"
aws s3 rm "s3://${ARTIFACT_BUCKET}" --recursive
aws s3 rb "s3://${ARTIFACT_BUCKET}"
```

---

## CloudFormation vs Terraform (same lab)

| Step | CloudFormation | Terraform |
|------|----------------|-----------|
| Define infra | `etl-stack.yaml` | `infra/terraform/*.tf` |
| Package Lambda | `deploy-cloudformation.sh` | automatic via `archive_file` |
| Preview | Change sets / console | `terraform plan` |
| Deploy | `aws cloudformation deploy` | `terraform apply` |
| Delete | `delete-stack` | `terraform destroy` |
| State | AWS-managed stack | Terraform state file |

**When to pick CloudFormation:** AWS-only teams, existing CFN pipelines, no extra tools to install.

**When to pick Terraform:** Multi-cloud, large module ecosystem, `plan` workflow across teams.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Bucket name already exists` | Change `ProjectPrefix` |
| `Template format error` | Run `validate-template` and fix YAML |
| `CAPABILITY_NAMED_IAM required` | Add `--capabilities CAPABILITY_NAMED_IAM` |
| Lambda runs but no output file | Confirm notification on raw bucket; path must be `incoming/*.csv` |
| `Unable to validate template` | Run commands from `day50-iac-serverless-wrapup/` |
| Stack stuck in `ROLLBACK_COMPLETE` | Delete stack, fix error, redeploy |

---

## Interview prep

### Q: What is Infrastructure as Code?

> Defining cloud resources in version-controlled templates instead of manual console work. CloudFormation uses YAML/JSON; changes are repeatable, reviewable, and reduce environment drift.

### Q: Why deploy Lambda code from S3 in CloudFormation?

> CloudFormation templates should stay small. Real deployment packages live in S3 (or CI/CD artifacts). The template references bucket + key, matching how CodePipeline and CodeBuild deploy Lambdas in production.

### Q: How do you secure database passwords?

> Store them in AWS Secrets Manager. CloudFormation generates the password with `GenerateSecretString`. Lambda reads it at runtime via IAM permission `secretsmanager:GetSecretValue` — never hardcode in code or template parameters.

---

## Quick command reference

```bash
# Deploy
./scripts/deploy-cloudformation.sh YOUR-PREFIX day50-etl-demo us-east-1

# Test
RAW=$(aws cloudformation describe-stacks --stack-name day50-etl-demo \
  --query "Stacks[0].Outputs[?OutputKey=='RawBucketName'].OutputValue" --output text)
aws s3 cp data/orders.csv "s3://${RAW}/incoming/orders.csv"

# Destroy
./scripts/destroy-cloudformation.sh day50-etl-demo us-east-1 YOUR-PREFIX
```

---

## Next steps

- Full Day 50 lab: [WALKTHROUGH.md](WALKTHROUGH.md)
- Terraform path: [IAC-STUDENT-GUIDE.md](IAC-STUDENT-GUIDE.md)
- AWS CloudFormation docs: https://docs.aws.amazon.com/cloudformation/
