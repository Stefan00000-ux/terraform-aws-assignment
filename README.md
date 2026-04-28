# terraform-aws-assignment
# AWS Infrastructure Automation with Terraform (Modular)

## 📌 Project Overview
This project demonstrates the deployment of a highly available and scalable web infrastructure on AWS using **Terraform**. The architecture is fully modularized to ensure reusability, maintainability, and clean code standards.

## 🏗️ System Architecture
The infrastructure consists of the following components:
* **Networking**: Custom VPC with Public and Private subnets across multiple Availability Zones.
* **Load Balancing**: An Application Load Balancer (ALB) to distribute incoming traffic.
* **Compute**: An Auto Scaling Group (ASG) managing EC2 instances running a web server.
* **Security**: Tiered Security Groups (ALB SG and Instance SG) following the principle of least privilege.

---

## 📂 Project Structure (Modular)
The project is organized into a root directory with three distinct modules:

```text
.
├── main.tf                # Root configuration (Calls all modules)
├── variables.tf           # Root input variables
├── outputs.tf             # Root outputs (ALB DNS Name)
└── modules/
    ├── vpc/               # Networking: VPC, Subnets, IGW, Route Tables
    │   ├── main.tf, variables.tf, outputs.tf
    ├── alb/               # Load Balancing: ALB, Target Group, Listeners
    │   ├── main.tf, variables.tf, outputs.tf
    └── ec2/               # Compute: Launch Template, Auto Scaling Group
        ├── main.tf, variables.tf, outputs.tf

Proof of Work & Evidence
Below are the screenshots confirming the modular setup and the AWS environment feedback:

1. Successful Initialization

![image alt](https://github.com/Stefan00000-ux/terraform-aws-assignment/blob/51a292f81456c329cc00fea6c9ccc12ce1408c58/tf_init.jpeg)



