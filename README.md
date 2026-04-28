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

## 💻 Full Source Code Implementation

This section contains the complete source code for the modular deployment. The project is divided into the Root configuration and three specialized modules.

---

### 📂 1. Root Configuration (main.tf)
*This is the main entry point for the project.*

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  #  (module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ec2" {
  source             = "./modules/ec2"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  desired_capacity   = var.desired_capacity
  alb_sg_id          = module.alb.alb_sg_id
}
#terraform {
#  backend "s3" {
#    bucket         = "stephen-final-assignment-77821" # Paste the name here
#    Key            = "terraform.tfstate"
#    region         = "us-east-1"
#    dynamodb_table = "terraform-lockid"
#    encrypt        = true
#  }
#})
}


**variables.tf (Root)**
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "desired_capacity" {
  type = number
}

**modules/vpc/main.tf**
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "main-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "private-subnet-${count.index}" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "main-nat" }
}

**modules/vpc/variables.tf**
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

**modules/alb/main.tf**
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Public access to the load balancer
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "main-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

**modules/alb/variables.tf**
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

**modules/ec2/main.tf**
resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] # Security requirement: Only ALB can talk to EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "web-server-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hi I'm Stephen !</h1>" > /var/www/html/index.html
              EOF
  )
}

**modules/ec2/variables.tf**

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "alb_sg_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

**outputs.tf (Root)**
output "load_balancer_url" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "final_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
(main-alb-1948317415.us-east-1.elb.amazonaws.com) [ALB- DNS - URL]
