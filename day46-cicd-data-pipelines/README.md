# Day 46: CI/CD for Data Pipelines

ETL Lambda (S3 → DynamoDB) with GitHub Actions CI and AWS CodePipeline CD.

## Start here

- **Masterclass:** [Day46-CI-CD-Data-Pipelines-Masterclass.md](Day46-CI-CD-Data-Pipelines-Masterclass.md)
- **Live MCP demo:** [demo/MCP-DEMO-GUIDE.md](demo/MCP-DEMO-GUIDE.md)
- **Student setup (console):** [demo/github-repo-staging/data-pipeline-cicd-demo/SETUP-WALKTHROUGH.md](demo/github-repo-staging/data-pipeline-cicd-demo/SETUP-WALKTHROUGH.md)
- **Student setup (CLI):** [demo/github-repo-staging/data-pipeline-cicd-demo/SETUP-WALKTHROUGH-CLI.md](demo/github-repo-staging/data-pipeline-cicd-demo/SETUP-WALKTHROUGH-CLI.md)

## Project layout

```
.github/workflows/ci-data-pipeline.yml   # CI: lint + pytest
buildspec.yml                           # CD: CodeBuild steps
lambda/etl_customer/                    # Lambda source
tests/                                  # Unit tests
infra/                                  # IAM + CodePipeline templates
data/                                   # Sample CSV
demo/                                   # MCP demo guide + staging repo clone
```

## Local test

Run all commands from this folder (`day46-cicd-data-pipelines/`):

```bash
cd day46-cicd-data-pipelines
pip install -r requirements-dev.txt
flake8 lambda tests --max-line-length=100
pytest tests/ -v
```

## Architecture

```
git push main → GitHub Actions (CI) + CodePipeline (CD)
CodePipeline: Source → CodeBuild → Lambda Deploy (alias prod)
```
