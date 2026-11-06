# Terraform: 3 EC2 instances in 3 AZs + ALB

## Prerequisites
Terraform >= 1.5, AWS CLI with valid credentials, AWS permissions, and available EC2 quota in us-east-1.

**Costs:** This is NOT guaranteed free. ALB and public IPv4 addresses incur charges; EC2 free-tier benefits depend on account eligibility/credits. Three instances may exceed free monthly compute allowances. Set an AWS Budget before applying.

## Open in VS Code
Extract the ZIP to `E:\terraform-alb-project` and choose **File > Open Folder**.

## Run in VS Code PowerShell terminal
```powershell
cd E:\terraform-alb-project
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output alb_url
```
Confirm `yes` for apply. Wait for the ALB targets to be healthy, then open the ALB URL.

## Verify
AWS EC2 console: three instances `running` in three distinct AZs. Target group: three `healthy` targets. ALB state: `active`.

## Common mistakes
- Invalid AWS credentials: run `aws sts get-caller-identity`.
- Unhealthy targets: allow a few minutes for cloud-init/Nginx; check EC2 security group and target health.
- Public IP / ALB costs: these are billable even when instances have credits.
- If `terraform apply` fails, inspect the error and fix only the affected resource before retrying.

## Cleanup (important)
```powershell
terraform destroy
```
Confirm `yes`; expect `Destroy complete!`. Run from the same folder with the original Terraform state. Verify in AWS Console that the ALB and EC2 instances are gone.

## Checklist
- [ ] AWS identity works
- [ ] Terraform validates
- [ ] Three EC2 instances running in distinct AZs
- [ ] ALB active, three healthy targets
- [ ] ALB URL responds
- [ ] `terraform destroy` complete

Memory trick: VPC → Subnets → Route → Security Groups → EC2 → Target Group → ALB → Listener.
