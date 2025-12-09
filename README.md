# Cross-Account IAM with AWS STS (Security Token Service)

This project demonstrates how to set up secure cross-account resource access in AWS. I demonstrate how to do this by leveraging AWS STS for short-live credentials.



## Architecture Diagram
<p text-align=center>
<img src=./assets/cross-account-iam.drawio.png
 width=90% >
</p>

---

## 🎯 Why This Project?
Most teams struggle with:
- Difficulty sharing data securely between accounts (S3, KMS, DynamoDB).
- Security teams unable to aggregate logs or enforce centralized controls.
- Frequent “AccessDenied” issues due to lack of understanding of identity-based vs resource-based policies.

**This project solves that** by demonstrating how to securely set up secure cross-account resource access by using IAM roles and temporary STS sessions. 


---

## 🛠️ Tech Stack
| Category       | Tools Used                                                                 |
|----------------|----------------------------------------------------------------------------|
| **Cloud**      | AWS (EC2, VPC, IAM, S3)                               |
| **IaC**        | Terraform (modular design)                                                 |
| **Security**   | IAM least-privilege roles                               |
| **App**        | A Python script that consumes the ISS satellite location-tracking API  |

<!-- | **CI/CD**      | -                                             |
| **Observability**| -                                              | -->

---

<!-- ## ⚡ Key Features
- **One-command deploy**: `terraform apply` provisions entire AWS environment -->
<!-- - **Zero secrets in code**: Uses GitHub OIDC to authenticate with AWS -->
<!-- - **Automated HTTPS**: ACM + Route 53 for free SSL certs
- **Real-time monitoring**: Grafana dashboards for API latency, error rates, and pod health
- **Cost-aware**: ~$22/month on AWS (breakdown in [costs.md](docs/costs.md)) -->

<!-- 🚫 Lessons Learned
Mistake: Initially used public RDS endpoint → fixed by placing DB in private subnet.
Surprise: GitHub OIDC setup took 3x longer than expected—but eliminated secret leaks!
Optimization: Switched to t3a.micro instances → saved 20% monthly cost.

📊 Cost & Maintenance
Estimated monthly cost: $22 (see cost breakdown)
Maintenance tasks:
Rotate IAM credentials quarterly
Review Terraform drift weekly
Upgrade EKS version every 6 months

🔒 Security Notes
Not for production as-is! This is a demo.
Hardened via:
VPC with private/public subnets
Encrypted EBS volumes + RDS
Least-privilege IAM roles for EKS pods
Full audit in SECURITY.md -->

## ▶️ How to Deploy

You'll need 2 AWS accounts, A & B. Configure CLI access to account A. Then create a tfvars file, like `dev.tfvars` and set the `account_b_id = <account_B_ID>`

Next, cd into the `./infra` directory and run:

```bash
terraform init

terraform plan -var-file ./dev.tfvars

# If the plan looks good, then run 
terraform apply -var-file ./dev.tfvars

```
 


Here's a video walkthrough of the project...


## ▶️ Video Walkthrough (2 min)

