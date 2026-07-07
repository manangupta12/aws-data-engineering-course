# Day 50: Infrastructure as Code & Serverless Wrap-up

End-to-end data engineering demo: **Python → Git → CI/CD → AWS (S3 + Secrets Manager + Lambda)**.

Covers Day 50 curriculum topics:

- Infrastructure as Code (Terraform + CloudFormation concepts)
- AWS Lambda for small ETL jobs
- Full pipeline review from code to cloud
- Securing database credentials with **AWS Secrets Manager**

## Quick start (local)

```bash
cd day50-iac-serverless-wrapup
pip install -r requirements-dev.txt
flake8 lambda tests --max-line-length=100
pytest tests/ -v
```

## Student walkthrough

- **Terraform step-by-step:** [IAC-STUDENT-GUIDE.md](IAC-STUDENT-GUIDE.md)
- **CloudFormation step-by-step:** [CLOUDFORMATION-STUDENT-GUIDE.md](CLOUDFORMATION-STUDENT-GUIDE.md)
- **Full Day 50 lab:** [WALKTHROUGH.md](WALKTHROUGH.md)

## Project layout

```
.github/workflows/ci-data-pipeline.yml   # CI: lint + pytest on push
buildspec.yml                            # CD: CodeBuild packaging steps
lambda/etl_orders/                       # Serverless ETL (S3 → S3)
tests/                                   # Unit tests (no AWS required)
data/orders.csv                          # Sample input
infra/terraform/                         # IaC: S3, Lambda, Secrets Manager
infra/cloudformation/etl-stack.yaml      # Same idea in CloudFormation
scripts/local-test.sh                    # Run tests locally
```

## Architecture

```
┌─────────────┐     git push      ┌──────────────────┐
│  Developer  │ ───────────────►  │ GitHub Actions   │
│  (Python)   │                   │ lint + pytest    │
└─────────────┘                   └────────┬─────────┘
                                         │ pass
                                         ▼
                              ┌──────────────────────┐
                              │ AWS CodePipeline     │
                              │ (optional CD path)   │
                              └──────────┬───────────┘
                                         ▼
┌──────────────┐   trigger    ┌─────────────────────┐   write    ┌──────────────┐
│ S3 raw bucket│ ───────────► │ Lambda (etl_orders) │ ─────────► │ S3 processed │
│ orders.csv   │              │ + Secrets Manager   │            │ JSON output  │
└──────────────┘              └─────────────────────┘            └──────────────┘
                                         │
                                         ▼ (concept)
                              ┌─────────────────────┐
                              │ RDS (Terraform opt.)│
                              │ password from secret│
                              └─────────────────────┘
```

## Related course material

- Day 46 CI/CD demo: [`day46-cicd-data-pipelines/`](../day46-cicd-data-pipelines/)
- Day 46 masterclass: [`day46-cicd-data-pipelines/Day46-CI-CD-Data-Pipelines-Masterclass.md`](../day46-cicd-data-pipelines/Day46-CI-CD-Data-Pipelines-Masterclass.md)
