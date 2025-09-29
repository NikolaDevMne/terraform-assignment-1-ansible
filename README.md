# AWS Infrastructure with Terraform + GitHub Actions

Provision and manage a simple AWS stack using **Terraform** with **GitHub Actions** for CI/CD.

---

## 🏗️ What this deploys

- **Networking**
  - VPC with **2 public** + **2 private** subnets across 2 AZs
  - Internet Gateway (NAT disabled by default)
  - DNS support/hostnames enabled

- **Compute**
  - EC2 instance (Ubuntu) in a public subnet
  - Elastic IP
  - Security groups for **SSH** and **HTTP/HTTPS**

- **Database**
  - RDS **MySQL 8.0** in private subnets
  - Master credentials stored in **AWS Secrets Manager**
  - DB SG allows access only from the app/EC2 SG

- **Identity**
  - EC2 IAM role + instance profile
  - Policy to **read the RDS master secret** (least-priv)

- **State**
  - Terraform remote state in **S3**
  - (Locking: S3 lockfile or DynamoDB if configured)

---

## 📦 Prerequisites

- Terraform **>= 1.11.0**
- AWS account + S3 bucket for remote state
- GitHub OIDC → AWS IAM role (role ARN stored as secret)
- (Optional) SSH public key if you still use SSH instead of SSM

---

## 🔐 Secrets & Configuration

Add repository **Actions secrets**:

- `AWS_ROLE_ARN` — IAM Role ARN assumed via OIDC by workflows

If you still want SSH:
- `SSH_PUBLIC_KEY` — your OpenSSH public key (used if wired in variables)

---

## 🗂️ Repository Structure

```plaintext
.
├── *.tf                 # Terraform modules/resources (VPC, EC2, RDS, IAM, SGs)
├── backend.tf           # S3 backend (bucket/key/region)
├── variables.tf         # Inputs (name, vpc_cidr, etc.)
├── outputs.tf           # Useful outputs (DB endpoint, secret ARN, etc.)
└── .github/
    └── workflows/
        ├── terraform_ci.yml        # PR checks & push-to-main apply
        └── terraform_destroy.yml   # Manual destroy (guarded)
```

---

## ⚙️ Workflows

### CI/CD (`.github/workflows/terraform_ci.yml`)
- **on: pull_request → main**
  - `terraform init`, `fmt -check`, `validate`, `plan` (speculative)
- **on: push → main**
  - `terraform init`, `fmt -check`, `validate`
  - `terraform plan -out=tfplan`
  - `terraform apply tfplan`

Uses AWS OIDC (`aws-actions/configure-aws-credentials@v4`) with `AWS_ROLE_ARN`.

### Destroy (`.github/workflows/terraform_destroy.yml`)
- **Manual** (`workflow_dispatch`)
- Requires typing **`DESTROY`** to proceed
- Runs `terraform plan -destroy` and then applies after approval

> The **state bucket** and **OIDC role** are intentionally **not** part of the destroy plan.

---

## 🚀 Quickstart

### Local (optional)
```bash
terraform init
terraform plan
terraform apply
```

### CI/CD
1. Push a feature branch and open a PR → checks + plan run automatically.
2. Merge to `main` → plan + apply run and deploy the infra.

### Destroy (manual)
1. GitHub → **Actions** → **Terraform Destroy** → **Run workflow**
2. Enter `DESTROY` and run
3. Review logs; infrastructure is torn down safely


## ❓ Troubleshooting
- **RDS connection timing**: New DBs take a few minutes; wait until status is `available`.