# Infrastructure as Code — Student Guide

**Follow this guide step by step.** No console clicking required for core setup.

**Project:** `day50-iac-serverless-wrapup/`  
**Time:** ~30 minutes (Terraform path) | ~20 minutes (CloudFormation path)  
**Cost:** S3 + Lambda + Secrets Manager stay in AWS free tier for lab use. Keep `enable_rds = false`.

---

## What you are building

| Resource | Purpose |
|----------|---------|
| S3 raw bucket | Upload CSV files (`incoming/orders.csv`) |
| S3 processed bucket | Store transformed JSON output |
| Lambda function | Serverless ETL on file upload |
| Secrets Manager secret | Secure DB password (not in code) |
| IAM roles | Least-privilege permissions for Lambda |

**Tools covered:** Terraform (primary) and CloudFormation (AWS-native alternative)

---

## Before you start — checklist

Copy this table and fill it in:

| Item | Your value |
|------|------------|
| AWS account ID | `________________` |
| AWS region | `________________` (e.g. `us-east-1`) |
| Unique prefix (lowercase) | `________________` (e.g. `jane-de-2026`) |
| AWS CLI configured? | `aws sts get-caller-identity` works? ☐ |
| Terraform installed? | `terraform version` shows 1.5+? ☐ |

### Install prerequisites

**AWS CLI:** https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

```bash
aws configure
aws sts get-caller-identity
```

**Terraform:** https://developer.hashicorp.com/terraform/install

```bash
terraform version
```

**Clone or open this project:**

```bash
cd day50-iac-serverless-wrapup
```

---

## Part A — Terraform (recommended path)

### Step 1: Understand the files

Open these files in order:

| File | What it defines |
|------|-----------------|
| `infra/terraform/variables.tf` | Inputs (region, prefix, optional RDS) |
| `infra/terraform/s3.tf` | Raw + processed S3 buckets |
| `infra/terraform/secrets.tf` | Secrets Manager + auto-generated password |
| `infra/terraform/lambda.tf` | Lambda function, IAM, S3 trigger |
| `infra/terraform/rds.tf` | Optional RDS (off by default) |
| `infra/terraform/outputs.tf` | Values you need after deploy |

**Key IaC idea:** These files are the **source of truth**. Git tracks changes. `terraform plan` shows what will change before anything is created.

---

### Step 2: Configure your variables

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_prefix = "jane-de-2026"   # CHANGE THIS — must be globally unique for S3
aws_region     = "us-east-1"
environment    = "dev"
enable_rds     = false             # keep false for free lab
```

> **Important:** S3 bucket names are global. Use your name + date in `project_prefix`.

`terraform.tfvars` is gitignored — never commit real prefixes or secrets.

---

### Step 3: Initialize Terraform

```bash
terraform init
```

**Expected output:** `Terraform has been successfully initialized!`

This downloads the AWS, random, and archive providers.

---

### Step 4: Preview changes (safe — creates nothing)

```bash
terraform plan
```

Read the plan carefully. You should see **~10–15 resources to add**, including:

- `aws_s3_bucket.raw`
- `aws_s3_bucket.processed`
- `aws_lambda_function.etl_orders`
- `aws_secretsmanager_secret.db_credentials`
- `aws_iam_role.lambda_execution`

**Green `+` = will be created.** No resources should show `-` (destroy) on first run.

If plan fails:

| Error | Fix |
|-------|-----|
| `No valid credential sources` | Run `aws configure` |
| `Invalid provider configuration` | Check `aws_region` in tfvars |
| `Archive creation error` | Run from `infra/terraform/`; Lambda source must exist at `../../lambda/etl_orders/` |

---

### Step 5: Deploy infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**Save the outputs:**

```bash
terraform output raw_bucket_name
terraform output processed_bucket_name
terraform output lambda_function_name
terraform output db_secret_arn
```

Example:

```
raw_bucket_name       = "jane-de-2026-orders-raw"
processed_bucket_name = "jane-de-2026-orders-processed"
lambda_function_name  = "jane-de-2026-etl-orders"
db_secret_arn         = "arn:aws:secretsmanager:us-east-1:123456789012:secret:jane-de-2026/rds/orders-db-AbCdEf"
```

---

### Step 6: Upload sample data and trigger ETL

From project root:

```bash
cd ../..
RAW=$(terraform -chdir=infra/terraform output -raw raw_bucket_name)
aws s3 cp data/orders.csv "s3://${RAW}/incoming/orders.csv"
```

Wait 5–10 seconds, then list processed output:

```bash
PROCESSED=$(terraform -chdir=infra/terraform output -raw processed_bucket_name)
aws s3 ls "s3://${PROCESSED}/processed/" --recursive
```

Download and inspect JSON:

```bash
KEY=$(aws s3 ls "s3://${PROCESSED}/processed/" --recursive | awk '{print $4}' | head -1)
aws s3 cp "s3://${PROCESSED}/${KEY}" -
```

**Expected:** Clean JSON array with normalized `amount`, `currency`, and `order_date`.

---

### Step 7: Verify Secrets Manager (no password in code)

```bash
SECRET_ARN=$(terraform -chdir=infra/terraform output -raw db_secret_arn)
aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text | python3 -m json.tool
```

**Expected:** JSON with `username`, `password`, `host`, `port`, `dbname`.

Your Python code loads this at runtime via `lambda/etl_orders/db_config.py` — not from Git.

---

### Step 8: View Lambda logs (optional)

```bash
FUNC=$(terraform -chdir=infra/terraform output -raw lambda_function_name)
aws logs tail "/aws/lambda/${FUNC}" --since 10m --follow
```

Press `Ctrl+C` to stop.

---

### Step 9: Make a change and see IaC in action

1. Edit `infra/terraform/s3.tf` — add a tag comment or change `memory_size` in `lambda.tf` from `256` to `512`
2. Run:

```bash
cd infra/terraform
terraform plan
terraform apply
```

**IaC benefit:** Change is reviewed (`plan`), versioned (Git), and applied consistently.

---

### Step 10: Clean up (avoid charges)

```bash
cd infra/terraform
terraform destroy
```

Type `yes`. Confirms all lab resources are removed.

---

## Part B — CloudFormation (AWS-native path)

Use this if your team standardizes on CloudFormation instead of Terraform.

### Step 1: Deploy the stack

From project root:

```bash
aws cloudformation deploy \
  --template-file infra/cloudformation/etl-stack.yaml \
  --stack-name day50-etl-demo \
  --parameter-overrides ProjectPrefix=YOUR-UNIQUE-PREFIX \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

Replace `YOUR-UNIQUE-PREFIX` with the same prefix you used for Terraform (lowercase, hyphens only).

---

### Step 2: Read stack outputs

```bash
aws cloudformation describe-stacks \
  --stack-name day50-etl-demo \
  --query "Stacks[0].Outputs" \
  --output table
```

Note `RawBucketName`, `ProcessedBucketName`, `LambdaFunctionName`, `DbSecretArn`.

---

### Step 3: Upload test file

```bash
aws s3 cp data/orders.csv s3://YOUR-RAW-BUCKET/incoming/orders.csv
```

> CloudFormation template ships placeholder Lambda code. For production-like ETL, deploy real code via CI/CD (`buildspec.yml`) or update the function zip manually after running tests locally.

---

### Step 4: Delete the stack

```bash
aws cloudformation delete-stack --stack-name day50-etl-demo
aws cloudformation wait stack-delete-complete --stack-name day50-etl-demo
```

---

## Terraform vs CloudFormation — quick comparison

| Topic | Terraform | CloudFormation |
|-------|-----------|----------------|
| Language | HCL (`.tf`) | YAML/JSON |
| Cloud support | Multi-cloud | AWS only |
| Preview command | `terraform plan` | Change sets (or `sam deploy`) |
| Deploy command | `terraform apply` | `aws cloudformation deploy` |
| State | Local or remote backend | AWS-managed stack state |
| Best for | Teams using multiple clouds | AWS-only shops |

**Interview line:** *"IaC means infrastructure is defined in version-controlled files, reviewed in PRs, and deployed repeatably — reducing manual errors and environment drift."*

---

## Common mistakes

| Mistake | Why it fails | Fix |
|---------|--------------|-----|
| Bucket name taken | S3 names are global | Change `project_prefix` |
| Wrong working directory | Terraform paths break | Always `cd infra/terraform` first |
| Skipped `terraform init` | Providers not downloaded | Run `init` after clone |
| Committed `terraform.tfvars` | Exposes your naming/secrets | Keep it gitignored |
| Left resources running | Small ongoing cost | Run `terraform destroy` |
| Uploaded file outside `incoming/` | S3 trigger filter misses file | Use `incoming/orders.csv` path |

---

## How IaC fits the full pipeline

```
Python ETL code  →  Git push  →  GitHub Actions (lint + test + terraform validate)
                                        ↓
                              terraform apply (or CodePipeline)
                                        ↓
                              S3 + Lambda + Secrets Manager live in AWS
                                        ↓
                              CSV upload triggers serverless ETL
```

Local validation before any cloud deploy:

```bash
./scripts/local-test.sh
```

---

## Interview prep (copy and adapt)

### Q: What are the benefits of Infrastructure as Code?

> IaC replaces manual console work with version-controlled definitions. Benefits: reproducible environments, faster onboarding, auditable changes in Git, safer reviews via plan/diff, and less configuration drift between dev and prod.

### Q: When would you use Lambda instead of EC2 for ETL?

> Lambda for short, event-driven jobs (file lands in S3, transform, write output) — pay per run, no server patching. EC2 for long-running jobs, heavy compute, or always-on workloads.

### Q: How do you secure database passwords in the cloud?

> Store credentials in AWS Secrets Manager, grant least-privilege IAM to read the secret, fetch at runtime via SDK. Never commit passwords to Git or hardcode in Lambda environment variables in the repo.

---

## Next steps

- Full Day 50 walkthrough: [WALKTHROUGH.md](WALKTHROUGH.md)
- Day 46 CI/CD (CodePipeline): [../day46-cicd-data-pipelines/](../day46-cicd-data-pipelines/)
- Terraform docs: https://developer.hashicorp.com/terraform/docs
- CloudFormation docs: https://docs.aws.amazon.com/cloudformation/

---

## Quick command reference

```bash
# Setup
cd day50-iac-serverless-wrapup/infra/terraform
cp terraform.tfvars.example terraform.tfvars   # edit prefix
terraform init
terraform plan
terraform apply

# Test ETL
RAW=$(terraform output -raw raw_bucket_name)
aws s3 cp ../../data/orders.csv "s3://${RAW}/incoming/orders.csv"

# Teardown
terraform destroy
```
