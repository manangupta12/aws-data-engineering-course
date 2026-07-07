# Day 50 Masterclass: Infrastructure as Code & Serverless Wrap-up

**Course:** Data Engineering — Week 10, Day 5 (Day 50)  
**Duration:** 60 minutes  
**Format:** Instructor-led, hands-on  
**Prerequisites:** Days 1–49 concepts (Python, Git, AWS S3, CI/CD from Day 46), AWS account  

> **Hands-on project:** [`day50-iac-serverless-wrapup/`](day50-iac-serverless-wrapup/)  
> **Student walkthrough:** [`day50-iac-serverless-wrapup/WALKTHROUGH.md`](day50-iac-serverless-wrapup/WALKTHROUGH.md)

---

## Learning Objectives

By the end of this session, learners will be able to:

1. Explain Infrastructure as Code (IaC) and compare Terraform vs CloudFormation at a concept level
2. Describe when AWS Lambda is appropriate for ETL vs EC2
3. Trace the end-to-end workflow: Python → Git → CI/CD → AWS (S3 / optional RDS)
4. Store database credentials in AWS Secrets Manager instead of source code
5. Answer Day 50 interview questions confidently

---

## Session Agenda (60 Minutes)

| Time | Segment | Activity |
|------|---------|----------|
| 0:00–0:10 | Concepts | IaC, serverless, course wrap-up arc |
| 0:10–0:20 | Code tour | Lambda ETL + Secrets Manager pattern |
| 0:20–0:35 | Hands-on Lab 1 | Local pytest + flake8 |
| 0:35–0:48 | Hands-on Lab 2 | `terraform plan` / optional `apply` |
| 0:48–0:55 | CloudFormation | Side-by-side syntax comparison |
| 0:55–1:00 | Interview prep | Q&A from WALKTHROUGH Part 9 |

---

## Curriculum mapping

| Day 50 topic | Project location |
|--------------|------------------|
| Terraform / CloudFormation (concept) | `infra/terraform/`, `infra/cloudformation/etl-stack.yaml` |
| AWS Lambda for small ETL | `lambda/etl_orders/` |
| End-to-end review | `.github/workflows/`, `buildspec.yml`, architecture in README |
| Secrets Manager | `infra/terraform/secrets.tf`, `lambda/etl_orders/db_config.py` |
| Interview questions | `WALKTHROUGH.md` Part 9 |

---

## Instructor notes

- Keep `enable_rds = false` in student labs to avoid RDS charges
- Emphasize `terraform plan` before `apply`
- Link back to Day 46 CodePipeline for full CD path
- Demo: upload `data/orders.csv` to raw S3 bucket → show JSON in processed bucket

---

## Related material

- [Day 46 CI/CD Masterclass](../day46-cicd-data-pipelines/Day46-CI-CD-Data-Pipelines-Masterclass.md)
- [Day 46 project](../day46-cicd-data-pipelines/)
