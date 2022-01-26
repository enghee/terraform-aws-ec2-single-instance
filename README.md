# terraform-aws-ec2-single

Terraform code to set up a simple ec2 instance in AWS cloud.

Requires:
1. AWS cli to be set up on client computer, with appropriate profile name

Steps:
1. Specify profile and region for the aws provider in main.tf
2. Specify the AZs for the subnets in main.tf
3. Review the security group cidr_blocks parameters, in particular, the CIDR range allowed for ssh in main.tf
4. Specify ami and instance_type in ec2.tf
5. Specify the ssh keypair name in var.tf
6. run terraform init, plan and apply accordingly.
