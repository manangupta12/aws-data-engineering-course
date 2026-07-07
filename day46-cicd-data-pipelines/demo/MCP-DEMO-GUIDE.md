# Day 46 Live Demo: CI/CD with GitHub + AWS MCP

**Duration:** ~15 minutes (instructor-led, during the 60-min masterclass)  
**Repo:** https://github.com/manangupta12/data-pipeline-cicd-demo  
**AWS Region:** `eu-north-1`  
**Project path:** run AWS CLI commands from `day46-cicd-data-pipelines/` (where `infra/` lives)

---

## What Was Provisioned

| Resource | Name / ARN | Status |
|----------|------------|--------|
| GitHub repo | `manangupta12/data-pipeline-cicd-demo` | Live — 2 commits on `main` |
| Lambda function | `etl-customer-s3-to-dynamodb` | Existing — version `1` published |
| Lambda alias | `prod` → version `1` | Created |
| S3 artifact bucket | `cicd-artifacts-211125491569-eu-north-1` | Created |
| CodeBuild project | `etl-customer-build` | Created |
| CodePipeline | `data-pipeline-etl-cd` (V2) | Created — Source stage pending connection |
| CodeStar Connection | `github-cicd-demo` | **PENDING** — requires one-time OAuth |

### Architecture

```
GitHub (main)
    │  GitHub Actions CI — lint + pytest on every push/PR
    │  CodePipeline Source — after connection is Available
    ▼
CodeBuild (buildspec.yml)
    │  flake8 → pytest → zip function.zip
    ▼
Lambda Deploy → etl-customer-s3-to-dynamodb:prod
```

---

## Pre-Demo: One-Time Setup (Instructor)

Complete the GitHub connection so CodePipeline can pull source code:

1. Open [CodePipeline Connections](https://eu-north-1.console.aws.amazon.com/codesuite/settings/connections?region=eu-north-1)
2. Select connection **`github-cicd-demo`**
3. Click **Update pending connection** → authorize GitHub
4. Wait until status is **Available**
5. Re-run the pipeline:

```bash
aws codepipeline start-pipeline-execution \
  --name data-pipeline-etl-cd \
  --region eu-north-1
```

---

## Demo Script (Use Cursor + MCP)

### Part 1 — GitHub MCP: Verify CI Repo (3 min)

**Prompt in Cursor:**

```
Using GitHub MCP get_me, confirm the authenticated user.
Then list_commits for owner manangupta12 repo data-pipeline-cicd-demo (last 3).
Then get_file_contents for .github/workflows/ci-data-pipeline.yml on main.
```

**Expected MCP tools:**

| Tool | Purpose |
|------|---------|
| `get_me` | Confirm GitHub identity |
| `list_commits` | Show pushes that trigger CI |
| `get_file_contents` | Read workflow YAML from remote |

**Live result (from this demo build):**

- User: `manangupta12`
- Latest commit: `cea7f06` — "Add Lambda code, workflow, and sample data"
- Workflow file present at `.github/workflows/ci-data-pipeline.yml`

**Talking point:** GitHub MCP lets you audit repo state without cloning — useful for platform/SRE tooling.

---

### Part 2 — GitHub Actions CI (2 min)

Open the repo Actions tab:

https://github.com/manangupta12/data-pipeline-cicd-demo/actions

**Instructor script:**

> "Every push runs flake8 and pytest in GitHub's build server. This is **Continuous Integration** — we catch bugs before merge, before AWS ever sees the code."

**Optional break-it demo:** Push a failing test via PR, show red check, fix, show green.

**Note:** GitHub MCP `push_files` / `create_or_update_file` may return `403` if the Cursor MCP token lacks write scope. Use `git push` or `gh` CLI as fallback; MCP read tools still work for inspection.

---

### Part 3 — AWS MCP: Inspect Pipeline State (5 min)

**Prompt in Cursor:**

```
Using AWS MCP:
1. aws codestar-connections get-connection for github-cicd-demo in eu-north-1
2. aws codepipeline get-pipeline-state --name data-pipeline-etl-cd --region eu-north-1
3. aws lambda get-function --function-name etl-customer-s3-to-dynamodb --region eu-north-1
Summarize each stage status and Lambda LastModified.
```

**Live result (before connection authorization):**

```json
ConnectionStatus: "PENDING"
Source stage: Failed — "Connection github-cicd-demo is not available"
Build stage: Not started
Deploy stage: Not started
Lambda LastModified: 2026-06-17T13:01:37.810+0000
```

**After connection is Available and pipeline succeeds:**

```json
Source → Succeeded
Build → Succeeded (flake8 + pytest + zip)
Deploy → Succeeded (Lambda alias prod updated)
Lambda LastModified: <new timestamp>
```

**Follow-up MCP prompt:**

```
Search AWS documentation for "CodePipeline Lambda deploy FunctionAlias"
and explain why we needed to publish version 1 and create alias prod.
```

**Answer for class:** CodePipeline Lambda deploy (V2) requires a published version and alias for safe rollbacks and traffic shifting.

---

### Part 4 — End-to-End Trace (3 min)

Walk the chain aloud while running MCP queries:

```
Step 1  GitHub MCP list_commits     → Who pushed what?
Step 2  GitHub Actions UI          → Did CI pass?
Step 3  AWS MCP get-pipeline-state → Did CD run?
Step 4  AWS MCP lambda get-function → Did LastModified change?
Step 5  AWS MCP lambda list-aliases → Is prod alias on new version?
```

**Optional invoke test:**

```
Using AWS MCP:
aws lambda invoke --function-name etl-customer-s3-to-dynamodb:prod \
  --payload '{"bucket":"testingrawdata","key":"data-etl-test1/customer.csv"}' \
  --region eu-north-1 /tmp/out.json
```

---

### Part 5 — Class Discussion (2 min)

| Question | Demo evidence |
|----------|---------------|
| CI vs CD? | GitHub Actions = CI; CodePipeline = CD |
| Continuous Delivery vs Deployment? | Add Approval stage between Build and Deploy |
| Build server role? | GitHub runner (CI) + CodeBuild (CD packaging) |

---

## MCP Tool Cheat Sheet

### GitHub MCP (`user-github-personal`)

```
get_me
list_commits          owner=manangupta12  repo=data-pipeline-cicd-demo
get_file_contents     path=.github/workflows/ci-data-pipeline.yml
search_pull_requests  query=repo:manangupta12/data-pipeline-cicd-demo is:open
create_pull_request   (requires write token scope)
push_files            (requires write token scope)
```

### AWS MCP (`user-aws-mcp`)

```
aws___call_aws
  aws codepipeline get-pipeline-state --name data-pipeline-etl-cd --region eu-north-1
  aws codepipeline list-pipeline-executions --pipeline-name data-pipeline-etl-cd --region eu-north-1
  aws codestar-connections list-connections --region eu-north-1
  aws lambda get-function --function-name etl-customer-s3-to-dynamodb --region eu-north-1
  aws lambda list-aliases --function-name etl-customer-s3-to-dynamodb --region eu-north-1

aws___search_documentation
  search_phrase: "CodePipeline Lambda deploy buildspec"
```

---

## Infrastructure Files (Course Repo)

All IaC used to provision this demo lives in `infra/`:

| File | Purpose |
|------|---------|
| `codebuild-project.json` | CodeBuild project definition |
| `codepipeline.json` | V2 pipeline: Source → Build → Deploy |
| `codebuild-trust-policy.json` | IAM trust for CodeBuild |
| `codepipeline-trust-policy.json` | IAM trust for CodePipeline |
| `codebuild-policy.json` | S3 + CloudWatch permissions |
| `codepipeline-policy.json` | CodeBuild, Lambda, Connection permissions |

**Re-provision commands:**

```bash
cd /Users/guptam8/Developer/DataEngineering/AWS

# One-time: publish Lambda version + alias
aws lambda publish-version --function-name etl-customer-s3-to-dynamodb --region eu-north-1
aws lambda create-alias --function-name etl-customer-s3-to-dynamodb --name prod --function-version 1 --region eu-north-1

# Create connection (complete OAuth in console)
aws codestar-connections create-connection --provider-type GitHub --connection-name github-cicd-demo --region eu-north-1

# Create build + pipeline (update ConnectionArn in codepipeline.json first)
aws codebuild create-project --cli-input-json file://infra/codebuild-project.json --region eu-north-1
aws codepipeline create-pipeline --cli-input-json file://infra/codepipeline.json --region eu-north-1
```

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Source stage: connection not available | Complete OAuth in CodeStar Connections console |
| GitHub MCP 403 on push | Use `git push` / `gh`; MCP read tools still work |
| Build fails on pytest import | Ensure `pytest.ini` has `pythonpath = lambda` |
| Deploy fails: alias not found | Run `aws lambda create-alias ... --name prod` |
| Pipeline not triggering on push | Connection must be Available; check branch is `main` |

---

## Cleanup (After Class)

```bash
aws codepipeline delete-pipeline --name data-pipeline-etl-cd --region eu-north-1
aws codebuild delete-project --name etl-customer-build --region eu-north-1
aws codestar-connections delete-connection --connection-arn <arn> --region eu-north-1
aws s3 rb s3://cicd-artifacts-211125491569-eu-north-1 --force
aws iam delete-role-policy --role-name data-pipeline-codepipeline-role --policy-name codepipeline-cicd-policy
aws iam delete-role --role-name data-pipeline-codepipeline-role
aws iam delete-role-policy --role-name data-pipeline-codebuild-role --policy-name codebuild-cicd-policy
aws iam delete-role --role-name data-pipeline-codebuild-role
gh repo delete manangupta12/data-pipeline-cicd-demo --yes
```

---

*Provisioned: 2026-06-23 | Account: 211125491569 | Region: eu-north-1*
